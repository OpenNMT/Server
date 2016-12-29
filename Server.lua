local zmq = require"zmq"
local json = require"json"

require('onmt.init')

local cmd = torch.CmdLine()

cmd:text("")
cmd:text("**onmt.translate.lua**")
cmd:text("")


cmd:option('-config', '', [[Read options from this file]])

cmd:text("")
cmd:text("**Data options**")
cmd:text("")

cmd:option('-src', '', [[Source sequence to decode (one line per sequence)]])
cmd:option('-tgt', '', [[True target sequence (optional)]])
cmd:option('-output', 'pred.txt', [[Path to output the predictions (each line will be the decoded sequence]])

onmt.translate.Translator.declareOpts(cmd)


cmd:text("")
cmd:text("**Other options**")
cmd:text("")
cmd:option('-gpuid', -1, [[ID of the GPU to use (-1 = use CPU, 0 = let cuda choose between available GPUs)]])
cmd:option('-fallback_to_cpu', false, [[If = true, fallback to CPU if no GPU available]])
cmd:option('-time', false, [[Measure batch translation time]])

local function init()
  local opt = cmd:parse(arg)

  local requiredOptions = {
    "model"
  }
  onmt.utils.Opt.init(opt, requiredOptions)
  onmt.translate.Translator.init(opt)
end

local function translate(line)
  local srcBatch = {}
  local srcWordsBatch = {}
  local srcFeaturesBatch = {}
  local srcTokens = {}
  for word in line:gmatch'([^%s]+)' do
    table.insert(srcTokens, word)
  end
  local srcWords, srcFeats = onmt.utils.Features.extract(srcTokens)
  table.insert(srcBatch, srcTokens)
  table.insert(srcWordsBatch, srcWords)
  if #srcFeats > 0 then
    table.insert(srcFeaturesBatch, srcFeats)
  end
  local data = onmt.translate.Translator.buildData(srcWordsBatch, srcFeaturesBatch,
                         tgtWordsBatch, tgtFeaturesBatch)
  local batch = data:getBatch()

  local pred, predFeats, predScore, attn, goldScore = onmt.translate.Translator.translateBatch(batch)
  
  local b = 1
  local ret = {}
  for i = 1, 5 do
    local predBatch = onmt.translate.Translator.buildTargetTokens(pred[b][i], predFeats[b][i], srcBatch[b], attn[b][i])
    local predSent = predBatch
    local attnTable = {}  
    for j = 1, #attn[b][i] do
      table.insert(attnTable, attn[b][i][j]:totable())
    end
    local srcSent = srcBatch[b]
    table.insert(ret, {message = predSent, attn = attnTable, src=srcSent})
  end
  return ret
end

local function main()
  init()
  local ctx = zmq.init(1)
  local s = ctx:socket(zmq.REP)
  
  s:bind("tcp://127.0.0.1:5556")
  print("initialized")
  while true do
    local message = json.decode(s:recv())
    local translate = translate(message.src)
    s:send(json.encode(translate))
    collectgarbage()
  end
end

main()
