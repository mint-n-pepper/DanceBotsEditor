#ifndef PRIMITIVE_LIST_H_
#define PRIMITIVE_LIST_H_

#include <QAbstractListModel>

class PrimitiveList :
  public QAbstractListModel {
  Q_OBJECT;

public:
  explicit PrimitiveList(QObject* parent);

  int rowCount(const QModelIndex& parent = QModelIndex()) const override;
  QVariant data(const QModelIndex& index, int role) const override;

public slots:
  void add(QObject* o);
private:
  QList<QObject*> mData;
};

#endif // PRIMITIVE_LIST_H_