#include <iostream>
#include <lame.h>
#include <BeatTrack.h>
#include <samplerate.h>
#include <sndfile.h>
#include <BeatTrack.h>
#include <QApplication>
#include <QtCore/QFile>
#include <QtCore/QDataStream>
#include <QtCore/QDebug>

int main(int argc, char* argv[]) {
	lame_t enc_gfp;
	enc_gfp = lame_init();

	hip_t dc_gfp;
	dc_gfp = hip_decode_init();
	// set encode mode to stereo
	lame_set_mode(enc_gfp, STEREO);
	lame_set_quality(enc_gfp, 2);
	id3tag_init(enc_gfp);
	id3tag_v1_only(enc_gfp);
	id3tag_set_title(enc_gfp, "This title");
	id3tag_set_artist(enc_gfp, "Robochoreographer");
	id3tag_set_comment(enc_gfp, "For Playback to Dancebot");
	char genre = 71;
	id3tag_set_genre(enc_gfp, &genre);
	lame_init_params(enc_gfp);

	mp3data_struct mp3data;
	lame_version_t lame_version;

	get_lame_version_numerical(&lame_version);

	qDebug() << "lame major " << lame_version.major << " minor: " << lame_version.minor;

	QFile in_file("../../../test/test_libraries/in.mp3");
	if (in_file.exists()) {
		qDebug() << "mp3 file found";
	}
	else {
		qDebug() << "mp3 file not found";
	}

	in_file.open(QIODevice::ReadOnly);

	QDataStream in_file_stream(&in_file);

	qint64 read_bytes = 1;

	const std::size_t kNBytesRead = 4096;
	const std::size_t kNBytesOutBuf = 100000;
	const std::size_t kPCMBuffer = kNBytesOutBuf * 2;
	unsigned char bytes[kNBytesRead] = { 0u };
	unsigned char out_bytes[kNBytesOutBuf] = { 0 };
	qint16 pcm_l[kPCMBuffer];
	qint16 pcm_r[kPCMBuffer];

	std::vector<float> mp3_data;

	bool show_header = true;

	while (read_bytes > 0) {
		read_bytes = in_file_stream.readRawData((char*)bytes, kNBytesRead);
		if (read_bytes > 0) {
			int n_decoded = hip_decode_headers(dc_gfp, bytes, kNBytesRead,
				pcm_l, pcm_r, &mp3data);
			//std::cout << "Got " << n_decoded << " bytes" << std::endl;
			if (show_header && mp3data.header_parsed) {
				show_header = false;
				qDebug() << "Mp3 header: stereo = " << mp3data.stereo;
				qDebug() << " sample rate = " << mp3data.samplerate;
				qDebug() << " bit rate = " << mp3data.bitrate;
				qDebug() << " mode = " << mp3data.mode;
				qDebug() << " mode_ext = " << mp3data.mode_ext;
				qDebug() << " framesize = " << mp3data.framesize;
			}
			// push into vector if there is data:
			for (uint32_t i = 0; i < n_decoded; ++i) {
				mp3_data.push_back(static_cast<float>(pcm_l[i] + pcm_r[i]) / 65536.f);
			}
		}
	}

	qDebug() << "vector has length: " << mp3_data.size();

	/* Do a sample rate conversion and write to wav file using libsndfile */
	quint64 target_sample_rate = 22050u;
	double sample_rate_ratio = static_cast<double>(target_sample_rate)
		/ static_cast<double>(mp3data.samplerate);
	long n_input_frames = static_cast<long>(mp3_data.size());
	double n_output_frames_d = static_cast<double>(n_input_frames) * sample_rate_ratio;
	long n_output_frames = static_cast<long>(n_output_frames_d) + 10;

	std::vector<float> output_vector = { 0 };
	output_vector.resize(n_output_frames);

	SRC_DATA resample_data;

	resample_data.data_in = mp3_data.data();
	resample_data.data_out = output_vector.data();
	resample_data.src_ratio = sample_rate_ratio;
	resample_data.input_frames = n_input_frames;
	resample_data.output_frames = n_output_frames;

	int error = src_simple(&resample_data, 2, 1);

	if (error) {
		qDebug() << "while resampling, got error code " << error;
	}

	SF_INFO sf_info;
	sf_info.channels = 1;
	sf_info.samplerate = target_sample_rate;
	sf_info.format = SF_FORMAT_WAV | SF_FORMAT_PCM_16;

	SNDFILE* outfile = sf_open("out.wav", SFM_WRITE, &sf_info);

	sf_count_t count = sf_writef_float(outfile, resample_data.data_out, resample_data.output_frames_gen);

	sf_write_sync(outfile);
	sf_close(outfile);

	const quint32 HOP_SIZE = 512;
	const quint32 WIN_SIZE = 2u * HOP_SIZE;
	const std::size_t N_HOPS = (mp3_data.size() / HOP_SIZE + 1);
	const std::size_t fvec_size = N_HOPS * HOP_SIZE;

	qDebug() << "fvec length is " << fvec_size;

	BeatTracker beatTrack(44100.0);

	float* plugin_buffer = new float[beatTrack.getPreferredBlockSize() + 2];

	float** plugbuf = &plugin_buffer;

	qDebug() << "Using block size = " << beatTrack.getPreferredBlockSize() << ", step size = " << beatTrack.getPreferredStepSize() << endl;

	Vamp::RealTime rt;
	Vamp::RealTime adjustment =  Vamp::RealTime::frame2RealTime(beatTrack.getPreferredBlockSize() / 2, int(44100.0 + 0.5));

	if (!beatTrack.initialise(1, beatTrack.getPreferredStepSize(), beatTrack.getPreferredBlockSize())) {
		qDebug() << "Beat Tracker failed to init.";
	};

	for (int i = 0; i < mp3_data.size(); i += beatTrack.getPreferredStepSize()) {

		int count = mp3_data.size() - i > beatTrack.getPreferredBlockSize() ? beatTrack.getPreferredBlockSize() : mp3_data.size() - i;
		int j = 0;
		while (j < count) {
			(*plugbuf)[j] = mp3_data.at(j + i);
			++j;
		}

		while (j < beatTrack.getPreferredBlockSize()) {
			(*plugbuf)[j] = 0.0f;
			++j;
		}

		rt = Vamp::RealTime::frame2RealTime(i, 44100);
		int frame = Vamp::RealTime::realTime2Frame(rt + adjustment, 44100);
		int sr = 44100;
		Vamp::Plugin::FeatureSet features = beatTrack.process(plugbuf, rt);
		if (features.find(0) != features.end()) {
			for (unsigned int k = 0; k < features.at(0).size(); ++k) {
				int displayFrame = frame;

				if (features[0][k].hasTimestamp) {
					displayFrame = Vamp::RealTime::realTime2Frame(features[0][k].timestamp, sr);
				}
				// add beat to BeatInfo object beatInf
				qDebug() << "got beat at: " << displayFrame;
			}
		}
	}

	Vamp::Plugin::FeatureSet features = beatTrack.getRemainingFeatures();

	if (features.find(0) != features.end()) {
		for (unsigned int k = 0; k < features.at(0).size(); ++k) {
			if (features[0][k].hasTimestamp) {
				int displayFrame = 0;
				displayFrame = Vamp::RealTime::realTime2Frame(features[0][k].timestamp + adjustment, 44100);
				float t_beat = features[0][k].timestamp.sec + features[0][k].timestamp.nsec / 1000000000.0;
				// add beat to BeatInfo object beatInf
				qDebug() << "got beat at: " << displayFrame << " sample; " << t_beat << "s";
			}
		}
	}

	in_file.close();
	lame_close(enc_gfp);
	return 0;
}