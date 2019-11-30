import QtQuick 2.0
import "../GuiStyle"

Item{
  id: root

  property var keys: null
  property bool hasChildren: (children.length > 0)
  width: parent.width
  height: parent.height
  property bool copy: false

  function startDrag(controlPressed){
    copy = controlPressed
    Drag.hotSpot.x = children[0].x;
    Drag.hotSpot.y = children[0].y + Style.primitives.height/2
    clearOccupancy() // clear occupancy
    if(copy){
      // copy primitives
      copyPrimitives()
    }
    Drag.start()
  }

  onChildrenChanged: {
    if(children.length > 1){
      // check newest child for being the same as the ones before
      if(children[children.length - 1 ].isFromBar
          !== children[children.length - 2 ].isFromBar){
        clean(children[children.length - 1])
      }
    }
  }

  function endDrag(){
    if(Drag.target === null){
      // dropped outside. Delete.
      deleteAll()
    }
    Drag.drop()
  }

  Drag.keys: keys
  Drag.dragType: Drag.Automatic

  function reset(){
    x = 0
    y = 0
  }

  function deleteAll(){
    var nChildren = children.length
    for(var i = 0; i < nChildren; ++i){
      var child = children[0]
      if(child.isFromBar){
        child.idleParent.model.remove(child.primitive)
      }else{
        child.destroy()
      }
    }
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

  function copyPrimitives(){
    if(!children[0].isFromBar){
      // don't have to copy, as dragged primitive is not from bar
      return
    }

    for(var i = 0; i < children.length; ++i){
      // clear it:
      children[0].idleParent.duplicateItem(children[i])
    }
  }

  function clean(whiteListItem){
    if(children.length === 0){
      return
    }

    var removeIndex = 0
    while(children.length > removeIndex && children[removeIndex]){
      if(children[removeIndex] === whiteListItem){
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
