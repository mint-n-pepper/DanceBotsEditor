#include "PrimitiveList.h"

PrimitiveList::PrimitiveList(QObject* parent) : QAbstractListModel{ parent } {};

int PrimitiveList::rowCount(const QModelIndex& parent) const{
  Q_UNUSED(parent);
  return mData.size();
}

QVariant PrimitiveList::data(const QModelIndex& index, int role) const {
  Q_UNUSED(role)
    return QVariant::fromValue(mData[index.row()]);
}

void PrimitiveList::add(QObject* o) {
  int i = mData.size();
  beginInsertRows(QModelIndex(), i, i);
  mData.append(o);
  o->setParent(this);
  endInsertRows();
}