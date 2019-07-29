#include <AudioFile.hpp>

#include <gtest/gtest.h>

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
    
    EXPECT_EQ(fake_file.LoadFile(),
              AudioFile::FileStatus::kFileDoesNotExist);
  }

  TEST_F(AudioFileTest, test44kFile) {
    // test opening a music mp3 file:

    AudioFile mp3_file_44k{ kFileFolderPath + "garbage_path"};
    mp3_file_44k.LoadFile(kFile_music_44k);

    EXPECT_FALSE(mp3_file_44k.is_dancefile());
  }

  TEST_F(AudioFileTest, testHeaderFile) {
    AudioFile mp3_file_header_test{ kFile_header_test };
    mp3_file_header_test.LoadFile();

    EXPECT_TRUE(mp3_file_header_test.is_dancefile());
  }

} // anon namespace

int main(int argc, char* argv[]) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}