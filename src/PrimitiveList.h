#ifndef PRIMITIVE_LIST_H_
#define PRIMITIVE_LIST_H_

#include <QAbstractListModel>

class PrimitiveList :
  public QAbstractListModel {
  Q_OBJECT;

  Q_PROPERTY(QObject* parent READ parent WRITE setParent);

public:
  explicit PrimitiveList(QObject* parent);

  int rowCount(const QModelIndex& parent = QModelIndex()) const override;
  QVariant data(const QModelIndex& index, int role) const override;
  Qt::ItemFlags flags(const QModelIndex& index) const override;
  bool setData(const QModelIndex& index,
               const QVariant& value,
               int role = Qt::EditRole) override;

public slots:
  void add(QObject* o);
  void remove(const int index);
  void printPrimitives(void) const;
  void callDataChanged(const int index);

protected:
  QHash<int, QByteArray> roleNames() const override;

private:
  QList<QObject*> mData;
};

#endif // PRIMITIVE_LIST_H_