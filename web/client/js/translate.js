class TranslateComponent extends VComponent {
    
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
        let form = this.parent.append("form");
        this.input = form
            .append("input")
            .attr("type","input");
        this.buttom =  form
            .append("input")
            .attr("value", "Translate")
            .attr("type", "button")
            .on("click",() => this.translate());
        this.output = form
            .append("input")
            .attr("type","input");
        this.svg = this.parent.append("svg").attr("width",2000).attr("height", 1000);
        let alignments = SVG.group(this.svg, "", {x: 0, y: 100});
        this.alignment = [new AlignmentComponent({parent: alignments})];
    }

    translate() {
        console.log(this.input.property("value"));
        $.ajax("/api/translate?src="+this.input.property("value"), {
            dataType : 'json',
            success: translation => {
                console.log(translation);
                // this.output.property("value", translation.message);
                this.alignment[0].update(translation[1]);
            }
        })
    }
    
    // RENDER/WRANGLE METHODS
    _wrangle(data) {
    }

    _render(renderData) {

    }

    // ACTION METHODS
    actionHoverCell(x, y, select) {
        const hovered = this.hm.selectAll(".x" + x + ".y" + y);
        hovered.classed('hovered', select);
        if (select) {
            const datum = hovered.datum();
            this.tooltip.attrs({
                opacity: 1,
                "transform": SVG.translate({
                    x: this.scaleX(datum.col),
                    y: this.scaleY(datum.row + 1) + 5
                })
            }).select('text').text(datum.label);
        } else {
            this.tooltip.attrs({opacity: 0});
        }
    }

    bindEvents(handler) {
        this.eventHandler = handler;
        handler.bind(this.events.cellHovered, (e, data) =>
          this.actionHoverCell(data.col, data.row, data.active));

        handler.bind(this.events.rectSelected, (e, hm_id) =>
          this.hm.selectAll('.mapping-rect-button').classed('selected', this.id == hm_id));

        handler.bind(this.events.circleSelected, (e, hm_id) =>
          this.hm.selectAll('.mapping-circle-button').classed('selected', this.id == hm_id));
    }
}

TranslateComponent;
