@widgets = {}
@charts = {}

Number.numberWithCommas = (x) ->
    parts = x.toString().split(".")
    parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    parts.join(".")
