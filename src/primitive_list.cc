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

#include "src/primitive_list.h"

#include <QDebug>

#include "src/primitive.h"

PrimitiveList::PrimitiveList(QObject* parent)
    : QAbstractListModel{parent}, mData{} {};

int PrimitiveList::rowCount(const QModelIndex& parent) const {
  Q_UNUSED(parent);
  return mData.size();
}

QVariant PrimitiveList::data(const QModelIndex& index, int role) const {
  if (Qt::UserRole + 1 == role && index.row() >= 0 &&
      index.row() < mData.size()) {
    return QVariant::fromValue(mData[index.row()]);
  } else {
    return QVariant();
  }
}

Qt::ItemFlags PrimitiveList::flags(const QModelIndex& index) const {
  return Qt::ItemIsSelectable | Qt::ItemIsEditable | Qt::ItemIsEnabled |
         Qt::ItemIsDragEnabled | Qt::ItemNeverHasChildren;
}

QHash<int, QByteArray> PrimitiveList::roleNames() const {
  QHash<int, QByteArray> roles;
  roles[Qt::UserRole + 1] = "item";
  return roles;
}

void PrimitiveList::add(QObject* o) {
  const int nData = mData.size();
  // start insertion notification
  // data inserted at top level, hence first arg. QModelIndex()
  beginInsertRows(QModelIndex(), nData, nData);
  mData.append(o);
  // take ownership
  // This is very important to prevent items to be garbage collected in JS!!!
  o->setParent(this);
  endInsertRows();
}

void PrimitiveList::remove(QObject* object) {
  // find index:
  size_t index = 0;
  for (auto& e : mData) {
    if (e == object) {
      break;
    }
    ++index;
  }

  // check if object was found
  if (index >= mData.length()) {
    return;
  }

  // start removal notification
  // data inserted at top level, hence first arg. QModelIndex()
  beginRemoveRows(QModelIndex(), index, index);
  mData.at(index)->setParent(nullptr);
  mData.removeAt(index);
  endRemoveRows();
}

void PrimitiveList::clear(void) {
  // don't need to clear if there is nothing
  if (mData.isEmpty()) {
    return;
  }
  beginRemoveRows(QModelIndex(), 0, mData.size() - 1);
  mData.clear();
  endRemoveRows();
}

void PrimitiveList::printPrimitives(void) const {
  size_t counter = 0;
  for (const auto& e : mData) {
    BasePrimitive* p = reinterpret_cast<BasePrimitive*>(e);
    qDebug() << "Item " << counter++ << " beatPos: " << p->mPositionBeat
             << ", beatL: " << p->mLengthBeat;
  }
}

void PrimitiveList::callDataChanged(const int index) {
  QModelIndex qmi = QAbstractItemModel::createIndex(index, 0);
  dataChanged(qmi, qmi, QVector<int>{Qt::UserRole + 1});
}

bool PrimitiveList::setData(const QModelIndex& index, const QVariant& value,
                            int role) {
  qDebug() << "setData row " << index.row() << " role " << role;
  dataChanged(index, index, QVector<int>{Qt::UserRole + 1});
  return true;
}

const QList<QObject*>& PrimitiveList::getData(void) { return mData; }
