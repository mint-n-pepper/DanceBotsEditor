/*
*  Dancebots GUI - Create choreographies for Dancebots
*  https://github.com/philippReist/dancebots_gui
*
*  Copyright 2019-2021 - mint & pepper
*
*  This program is free software : you can redistribute it and/or modify
*  it under the terms of the GNU General Public License as published by
*  the Free Software Foundation, either version 3 of the License, or
*  (at your option) any later version.
*
*  This program is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*
*  See the GNU General Public License for more details, available in the
*  LICENSE file included in the repository.
*/

import QtQuick 2.6
import "../GuiStyle"

Item{
  id: root

  property var keys: null
  property bool hasChildren: (children.length > 0)
  property bool copy: false
  property bool dragActive: Drag.active

  property real minChildX: 0.0
  property real maxChildX: 0.0
  property real hotSpotOffsetX: 0.0

  property int beatOffset: 0

  signal dragXChanged(int minChildX, int maxChildX)

  function startDrag(controlPressed){
    copy = controlPressed
    calculateEdges()
    // set hotspot to center of dragged primitives
    hotSpotOffsetX = (maxChildX - minChildX) / 2
    Drag.hotSpot.x = minChildX + hotSpotOffsetX
    Drag.hotSpot.y = children[0].y + children[0].height / 2

    // if the primitives are from the bar, shrink the auto-scroll boundaries
    // if the primitive set is wider than the area shown
    if(children[0].isFromBar){
      checkBarBoundaries()
    }

    // clear timer bar occupancy
    clearOccupancy()

    if(copy){
      // copy primitives
      copyPrimitives()
    }
    Drag.start()
  }

  onHasChildrenChanged: {
    // if a child is added, make sure the other dragger is cleaned
    if(hasChildren){
      cleanOther()
    }
  }

  onXChanged: {
    // only process if we are hovering over the timer bar
    if(Drag.active && Drag.target){
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

  function checkBarBoundaries(){
    // check if scroll margins are already exceeded and adjust if necessary:
    if(minChildX <
        timerBarFlickable.contentX + timerBarFlickable.scrollMargin){
      // set minChildX slightly above scroll threshold
      minChildX = timerBarFlickable.contentX
                  + 1.1 * timerBarFlickable.scrollMargin
    }

    if(maxChildX >
        timerBarFlickable.contentX
        + timerBarFlickable.width
        - timerBarFlickable.scrollMargin){
      // set maxChildX slightly below scroll threshold
      maxChildX = timerBarFlickable.contentX
                  + timerBarFlickable.width
                  - 1.1 * timerBarFlickable.scrollMargin
    }
  }

  function calculateEdges(){
    // calculate left and right edges of children
    minChildX = children[0].x
    beatOffset = children[0].primitive.positionBeat
    maxChildX = children[0].x + children[0].width

    for(var i = 1; i < children.length; ++i){
      if(children[i].x < minChildX){
        minChildX = children[i].x
        beatOffset = children[i].primitive.positionBeat
      }
      if(children[i].x + children[i].width > maxChildX){
        maxChildX = children[i].x + children[i].width
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
