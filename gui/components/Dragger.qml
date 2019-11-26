import QtQuick 2.0
import "../GuiStyle"

Item{
  id: root

  property var keys: null
  property bool hasChildren: (children.length > 0)

  function startDrag(controlPressed){
    console.log("drag started with controlPressed" + controlPressed);
    Drag.hotSpot.x = children[0].x;
    Drag.hotSpot.y = children[0].y + Style.primitives.height/2
    clearOccupancy()
    Drag.start()
  }

  onChildrenChanged: {
    console.log('Nchildren = ' + children.length)
    if(children.length > 1){
      // check newest child for being the same as the ones before
      if(children[children.length - 1 ].isFromBar
          !== children[children.length - 2 ].isFromBar){
        clean(children[children.length - 1])
      }
    }
  }

  function endDrag(){
    console.log("Drag end")
    Drag.drop()
  }

  Drag.keys: keys
  Drag.dragType: Drag.Automatic

  function reset(){
    x = 0
    y = 0
  }

  function clearOccupancy(){
    if(!children[0].isFromBar){
      // don't have to clear, as dragged primitive is not from bar
      return
    }

    for(var i = 0; i < children.length; ++i){
      // clear it:
      children[0].idleParent.parent.freeOccupied(children[i].primitive)
    }
  }

  function clean(whiteListItem){
    if(children.length === 0){
      return
    }

    var removeIndex = 0
    while(children.length > removeIndex && children[removeIndex]){
      if(children[removeIndex] === whiteListItem){
        console.log("continue")
        removeIndex = 1
        continue
      }
      children[removeIndex].deselect()
    }

    if(!children.length){
      reset()
    }
  }
}
