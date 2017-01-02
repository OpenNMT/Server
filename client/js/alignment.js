class AlignmentComponent extends VComponent {
    
    get events() {
        return {
        }
    }

    get defaultOptions() {
        return {
        }
    }

    // Data Style
    get _dataStyle() {
        return {
        }
    }


    // INIT METHODS
    _init() {
        this.base = this.parent.append("g")
    }
    
    _wrangle(data) {
        let attn = [];
        _.map(data.attn, (d, i) => _.map(d, (v, j) => attn.push({src: j, tgt: i, val: v})));
        data.attnGroup = attn;
        return data;
    }

    
    _render(renderData) {
        let xWord = d3.scaleLinear().domain([0,25]).range([0, 1500]);
        console.log(renderData.src);
        this.src = this.base.append("g");

        
        const src_words = this.src.selectAll("g")
              .data(renderData.src)
              .enter();
        src_words
            .append("g")
            .attr("transform", (d, i) => "translate(" + xWord(i) + ", 0)")
            .append("text")
            .text(d => d);

        this.tgt = this.base.append("g").attr("transform", "translate(0, 100)")

        const tgt_words = this.tgt.selectAll("g")
              .data(renderData.message)
              .enter();
        tgt_words
            .append("g")
            .attr("transform", (d, i) => "translate(" + xWord(i) + ", 0)")
            .append("text")
            .text(d => d);

        console.log(renderData.attnGroup);
        this.base.selectAll(".attn")
            .data(renderData.attnGroup)
            .enter()
            .append("line")
            .classed("attn", true)
            .attr("x1", d => xWord(d.src) + (xWord(0.5) -xWord(0)))
            .attr("x2", d => xWord(d.tgt) + (xWord(0.5) -xWord(0)))
            .attr("y1", 10)
            .attr("y2", 90)
            .style("stroke", "black")
            .style("opacity", d => d.val);
        

    }
}

AlignmentComponent;
