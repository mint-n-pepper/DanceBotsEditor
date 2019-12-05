import QtQuick 2.0
import "../GuiStyle"

Item{
  id: root

  property var keys: null
  property bool hasChildren: (children.length > 0)
  property bool copy: false
  property bool dragActive: Drag.active

  signal dragXChanged(int minChildX, int maxChildX)

  function startDrag(controlPressed){
    copy = controlPressed
    Drag.hotSpot.x = children[0].x
    Drag.hotSpot.y = children[0].y + Style.primitives.height/2
    clearOccupancy() // clear occupancy
    if(copy){
      // copy primitives
      copyPrimitives()
    }
    Drag.start()
  }

  onXChanged: {
    // only process if we are hovering over the timer bar
    if(Drag.active && Drag.target){
      // calculate left and right edges of children
      var minChildX = children[0].x
      var maxChildX = children[0].x + children[0].width

      for(var i = 1; i < children.length; ++i){
        if(children[i].x < minChildX){
          minChildX = children[i].x
        }
        if(children[i].x + children[i].width > maxChildX){
          maxChildX = children[i].x + children[i].width
        }
      }

      dragXChanged(x + minChildX, x + maxChildX)
    }
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
      reset()
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
      // copy it:
      children[0].idleParent.duplicateItem(children[i])
    }
  }

  function cleanAll(){
    while(children.length){
      children[0].deselect()
    }
  }

  function clean(whiteListItem){
    cleanOther()
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
