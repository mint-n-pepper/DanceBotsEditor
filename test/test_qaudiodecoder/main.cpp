#include <gtest/gtest.h>
#include "Decoder.h"

namespace {
  class DecoderTest : public ::testing::Test {
  protected:
    static void SetUpTestSuite(void) {
      // init
    }

    static void TearDownTestSuite(void) {
      // cleanup temp file
    }

    static const QString fileFolderPath;
    static const QString fileMusic;
  };

  const QString DecoderTest::fileFolderPath{ "./../test_mp3_files/" };
  const QString DecoderTest::fileMusic{ fileFolderPath + "dp_badEncode.mp3" };

  TEST_F(DecoderTest, testSave) {
    Decoder decoder{};

    QFile inFile(fileMusic);
    inFile.open(QIODevice::ReadOnly);

    QByteArray data = inFile.read(inFile.size());

    decoder.decode(data);

  }
} // anon namespace

int main(int argc, char* argv[]) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
