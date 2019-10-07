#include <AudioFile.h>
#include <math.h>
#include <limits.h>

#include <QtCore/QFile>

int main(int argc, char* argv[]) {
  const QString kFileFolderPath{ "./../test_mp3_files/" };
  const QString kFile_music_22k{ kFileFolderPath + "in22050.mp3" };
  const QString kFile_music_44k{ kFileFolderPath + "in44100.mp3" };
  const QString kFile_header_test{ kFileFolderPath + "header_test.mp3" };

  AudioFile mp3_file{};
  mp3_file.Load(kFile_music_44k);

  bool use_sinusoid = false;

  if (use_sinusoid) {

    const double fs = 44100.0;
    const double ftone = 441.0;
    const double t_tone = 0.2;
    const double amplitude = 0.2;
    const double PI = 3.141592653589793238463;

    // figure out lenghts of tone and file
    const size_t n_file_samples = 3 * 44100; // 10 sec file
    const size_t n_samples_tone_period = fs / ftone;
    const size_t n_tone_samples = size_t(t_tone * ftone) * n_samples_tone_period;

    // clear the header data and reset:
    mp3_file.mp3_prepend_data_.clear();
    mp3_file.mp3_prepend_data_.resize(100);

    for (auto& i : mp3_file.mp3_prepend_data_) {
      i = 0;
    }

    // clear the pcm data:
    mp3_file.float_data_.clear();
    mp3_file.float_music_.clear();

    mp3_file.float_music_.resize(n_file_samples);
    mp3_file.float_data_.resize(n_file_samples);
    const double dt = 1 / fs;
    double t = 0.0;
    for (auto& i : mp3_file.float_music_) {
      double theta = 2.0 * PI * ftone * t;
      t = t + dt;
      i = static_cast<float>(amplitude * sin(theta));
    }
  }

  // write both beeps:
  //for (size_t i = 0; i < n_tone_samples; ++i) {
  //  double theta = 2.0 * PI * ftone * i / fs;
  //  double vald = amplitude * sin(theta);
  //  qint16 pcm = vald * SHRT_MAX;
  //  mp3_file.pcm_music_.at(i) = pcm;
  //  mp3_file.pcm_music_.at(n_file_samples - n_tone_samples + i) = pcm;
  //}
  mp3_file.SavePCM(kFileFolderPath + "encode_test.wav");
  mp3_file.Save(kFileFolderPath + "encode_test.mp3");
  mp3_file.Save(kFileFolderPath + "encode_test_dc.mp3");

  const size_t N_CYCLES = 100;

  for (size_t i = 0; i < N_CYCLES; ++i) {
    AudioFile mp3_file{ };
    mp3_file.Load(kFileFolderPath + "encode_test_dc.mp3");
    if (i == N_CYCLES - 1) {
      mp3_file.SavePCM(kFileFolderPath + "encode_test_dc.wav");
    }
    mp3_file.Save(kFileFolderPath + "encode_test_dc.mp3");
  }

  return 0;
}