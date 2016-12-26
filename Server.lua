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

cmd:option('-model', '', [[Path to model .t7 file]])
cmd:option('-src', '', [[Source sequence to decode (one line per sequence)]])
cmd:option('-tgt', '', [[True target sequence (optional)]])
cmd:option('-output', 'pred.txt', [[Path to output the predictions (each line will be the decoded sequence]])

-- beam search options
cmd:text("")
cmd:text("**Beam Search options**")
cmd:text("")
cmd:option('-beam_size', 5,[[Beam size]])
cmd:option('-max_sent_length', 250, [[Maximum sentence length. If any sequences in srcfile are longer than this then it will error out]])
cmd:option('-replace_unk', false, [[Replace the generated UNK tokens with the source token that
                              had the highest attention weight. If phrase_table is provided,
                              it will lookup the identified source token and give the corresponding
                              target token. If it is not provided (or the identified source token
                              does not exist in the table) then it will copy the source token]])
cmd:option('-phrase_table', '', [[Path to source-target dictionary to replace UNK
                                     tokens. See README.md for the format this file should be in]])
cmd:option('-n_best', 1, [[If > 1, it will also output an n_best list of decoded sentences]])

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
  
  local predBatch, info = onmt.translate.Translator.translate(srcWordsBatch, srcFeaturesBatch,
                                                              tgtWordsBatch, tgtFeaturesBatch)
  
  local srcSent = table.concat(srcBatch[1], " ")
  local predSent = table.concat(predBatch[1], " ") 
  return predSent
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
    s:send(json.encode({message = translate}))
    collectgarbage()
  end
end

main()
