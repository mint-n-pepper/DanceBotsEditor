#include <AudioFile.hpp>

#include <gtest/gtest.h>
#include <QtCore/QFile>

namespace {
  class AudioFileTest : public ::testing::Test {
  protected:
    static void SetUpTestSuite(void) {
      // init
    }

    static void TearDownTestSuite(void) {
      // cleanup
    }

    static const QString kFileFolderPath;
    static const QString kFile_music_44k;
    static const QString kFile_music_22k;
    static const QString kFile_header_test;
  };

  const QString AudioFileTest::kFileFolderPath{ "./../test_mp3_files/" };
  const QString AudioFileTest::kFile_music_22k{ kFileFolderPath + "in22050.mp3" };
  const QString AudioFileTest::kFile_music_44k{ kFileFolderPath + "in44100.mp3" };
  const QString AudioFileTest::kFile_header_test{ kFileFolderPath 
    + "header_test.mp3" };

  TEST_F(AudioFileTest, testAudioFileNotExist) {
    // test opening a fake file:
    const QString kFakeFileName("fakefakefile.mp3");

    AudioFile fake_file{ kFileFolderPath + kFakeFileName };
    
    EXPECT_EQ(fake_file.GetStatus(),
              AudioFile::FileStatus::kFileDoesNotExist);
  }

  TEST_F(AudioFileTest, testSave) {
    AudioFile mp3_file_44k{ kFile_music_44k };

    const size_t kNPrePendData = 1024 + 128 + 16 + 2;

    for (size_t i = 0; i < kNPrePendData; ++i) {
      mp3_file_44k.GetPrePendData().append(static_cast<char>(i));
    }

    // set artist and title:
    mp3_file_44k.SetArtist("Daft Punk");
    mp3_file_44k.SetTitle("Face to Face");

    mp3_file_44k.Save(kFileFolderPath + "out.mp3");
  }

  TEST_F(AudioFileTest, test44kFile) {
    // test opening a music mp3 file:

    AudioFile mp3_file_44k{ kFile_music_44k};

    ASSERT_EQ(mp3_file_44k.GetStatus(), AudioFile::FileStatus::kOk);

    EXPECT_FALSE(mp3_file_44k.is_dancefile());

    // make sure mp3 data is read from beginning of file
    // if test file is not a dance file
    QFile test_file{ kFile_music_44k };

    test_file.open(QIODevice::ReadOnly);

    const size_t kNRead = 100;
    QByteArray test_data = test_file.read(kNRead);

    const char* mp3_file_data = mp3_file_44k.GetRawMP3Data();

    for (size_t i = 0; i < test_data.size(); ++i) {
      EXPECT_EQ(mp3_file_data[i], test_data.data()[i]);
    }

    // test tag data:
    EXPECT_STREQ(mp3_file_44k.GetArtist().c_str(), "Daft Punk");
    EXPECT_STREQ(mp3_file_44k.GetTitle().c_str(), "Face To Face");
    EXPECT_EQ(mp3_file_44k.GetSampleRate(), 44100);
  }

  TEST_F(AudioFileTest, testHeaderFile) {
    AudioFile mp3_file_header_test{ kFile_header_test };
  
    EXPECT_EQ(mp3_file_header_test.GetStatus(), AudioFile::FileStatus::kOk);
    EXPECT_TRUE(mp3_file_header_test.is_dancefile());
  }

  TEST_F(AudioFileTest, test_many_en_decodes) {
    AudioFile mp3_file_header_test{ kFile_header_test };
    mp3_file_header_test.Save(kFileFolderPath + "cycle_test.mp3");

    for (uint a = 0; a < 10; ++a) {
      AudioFile mp3_file_cycle_test{ kFileFolderPath + "cycle_test.mp3" };
      mp3_file_cycle_test.Save(kFileFolderPath + "cycle_test.mp3");
    }
  }

} // anon namespace

int main(int argc, char* argv[]) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}