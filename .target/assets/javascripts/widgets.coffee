container = _.template("""<div id="<%= id %>" class="popover-container"></div>""")
content = _.template("""
                     <table>
                       <% _.each(datum, function(value, key) { %>
                         <tr class="popover-element">
                           <td class="popover-key"><%= key %></td>
                           <td class="popover-value"><%= value %></td>
                         </tr>
                       <% }); %>
                     </table>
                     """)
$ -> $("body").append("""<div id="popovers"></div>""")
domId = (uid) -> "popover_#{uid}"
widgets.Popovers = {
  
  create: (uid) ->
    popoverId = domId(uid)
    if $("##{popoverId}").length is 0
      $("#popovers").append(container({ id: popoverId }))
      @hide(uid)
      
  hide: (uid) ->
    $("##{domId(uid)}").hide()
    
  show: (uid, obj) ->
    $("##{domId(uid)}").html(content({ datum: obj })).show()
    
  position: (uid, x, y, bottomBound, rightBound) ->
    if rightBound
      boxWidth = $("##{domId(uid)}").width()
      if x+boxWidth > rightBound
        x -= boxWidth+40
    if bottomBound
      boxHeight = $("##{domId(uid)}").height()
      if y+boxHeight > bottomBound
        y -= boxHeight+40
    $("##{domId(uid)}").css({ top: y, left: x })
    
}