import 'package:bmi_calculator/presentation/main/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _bcsController = TextEditingController();
  String? _bcsErrorText;

  Widget _buildImageWithText({
    required String imageAsset,
    required String scoreText,
    required String scoreDescription,
  }) {
    return Column(
      children: [
        Image.asset(
          imageAsset,
          width: 200, // 이미지 너비 조절
          height: 200, // 이미지 높이 조절
        ),
        Text(
          scoreText,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          scoreDescription,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.normal),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    load();
    _resetFields(); // 앱이 시작될 때마다 값 초기화
  }

  @override
  void dispose() {
    _weightController.dispose();
    _bcsController.dispose();
    super.dispose();
  }

  Future save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('weight', double.parse(_weightController.text));
    await prefs.setDouble('bcs', double.parse(_bcsController.text));
  }

  Future load() async {
    final prefs = await SharedPreferences.getInstance();
    final double? weight = prefs.getDouble('weight');
    final double? bcs = prefs.getDouble('bcs');

    setState(() {
      _weightController.text = weight?.toStringAsFixed(0) ?? ''; // 정수 형식으로 초기화
      _bcsController.text = bcs?.toStringAsFixed(0) ?? ''; // 정수 형식으로 초기화
      _bcsErrorText = null; // 에러 메시지 초기화
    });
  }

  String? _validateBcs(String? value) {
    if (value == null || value.isEmpty) {
      return 'BCS 점수를 입력하세요';
    }

    final bcs = int.tryParse(value);
    if (bcs == null || bcs < 1 || bcs > 9) {
      return 'BCS 점수는 1부터 9까지 입력 가능합니다';
    }

    return null; // 유효성 검사 통과
  }

  Future<void> _resetFields() async {
    setState(() {
      _weightController.text = ''; // 현재 체중 입력 초기화
      _bcsController.text = ''; // BCS 점수 입력 초기화
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('weight'); // 기존에 저장된 체중 데이터 삭제
    await prefs.remove('bcs'); // 기존에 저장된 BCS 점수 데이터 삭제

    setState(() {
      _bcsErrorText = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              height: 380.0,
              child: Image.asset(
                'assets/dog_head.png',
                fit: BoxFit.fill,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 60),
                  TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orangeAccent)),
                      hintText: '현재 체중 kg',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '현재 체중을 입력하세요';
                      }
                      final weight = int.tryParse(value);
                      if (weight == null || weight < 1 || weight > 99) {
                        return '현재 체중은 1부터 99까지 입력 가능합니다';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _bcsController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orangeAccent)),
                      hintText: 'BCS 점수',
                    ),
                    keyboardType: TextInputType.number,
                    validator: _validateBcs,
                    autovalidateMode:
                        _bcsErrorText != null // 에러 메시지가 있을 때만 자동 유효성 검사 활성화
                            ? AutovalidateMode.always
                            : AutovalidateMode.disabled,
                    onChanged: (value) {
                      setState(() {
                        _bcsErrorText = null; // 입력이 변경되면 에러 메시지 초기화
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (BuildContext context) {
                              return Dialog(
                                backgroundColor: Colors.white,
                                child: Container(
                                  width: 800, // 원하는 넓이로 변경
                                  height: 600, // 원하는 높이로 변경
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'BCS 점수 측정법',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Expanded(
                                        child: ListView(
                                          children: [
                                            _buildImageWithText(
                                              imageAsset:
                                                  'assets/dog_image1_rate.png',
                                              scoreText:
                                                  '매우 마른 단계 (BCS 1 ~ 3 점)',
                                              scoreDescription:
                                                  '육안으로 봤을 때 뼈가 보이거나 \n 가슴을 쓰다듬었을 때 뼈가 느껴집니다. \n 갈비뼈와 허리등뼈(요추), 골반뼈가 잘 보이고 \n 만져지며 근육량과 체지방이 적은 상태입니다.',
                                            ),
                                            _buildImageWithText(
                                              imageAsset:
                                                  'assets/dog_image2_rate.png',
                                              scoreText: '두번째 점수',
                                              scoreDescription:
                                                  ' 두번째 점수에 대한 설명글',
                                            ),
                                            _buildImageWithText(
                                              imageAsset:
                                                  'assets/dog_image3_rate.png',
                                              scoreText: '첫 번째 점수',
                                              scoreDescription:
                                                  '첫 번째 점수에 대한 설명글',
                                            ),
                                            _buildImageWithText(
                                              imageAsset:
                                                  'assets/dog_image4_rate.png',
                                              scoreText: '첫 번째 점수',
                                              scoreDescription:
                                                  '첫 번째 점수에 대한 설명글',
                                            ),
                                            _buildImageWithText(
                                              imageAsset:
                                                  'assets/dog_image5_rate.png',
                                              scoreText: '첫 번째 점수',
                                              scoreDescription:
                                                  '첫 번째 점수에 대한 설명글',
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFF2AB65),
                                          //
                                        ),
                                        child: const Text(
                                          '닫기',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold, //
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent, // 버튼 배경색상 변경
                        ),
                        child: const Text(
                          'BCS 점수 측정법',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold, // 버튼 글자색 변경
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed:
                                _resetFields, // _resetFields() 메서드를 호출하도록 변경
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: Colors.orangeAccent,
                            ),
                            child: Center(
                              child: GestureDetector(
                                onTap: _resetFields,
                                child: Container(
                                  width: 40, // 아이콘의 넓이 조절
                                  height: 40, // 아이콘의 높이 조절
                                  child: const Icon(
                                    Icons.refresh,
                                    size: 24,
                                    color: Colors.white, // 아이콘 색상 설정
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 3),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState?.validate() == false) {
                                setState(() {
                                  _bcsErrorText = 'BCS 점수를 입력하세요';
                                });
                                return;
                              }
                              save();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoadingScreen(
                                    weight:
                                        double.parse(_weightController.text),
                                    bcs: double.parse(_bcsController.text),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent, // 배경색 설정
                            ),
                            child: const Hero(
                              tag: 'result_button_tag',
                              child: Text(
                                '결과',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold, // 글자색 설정
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
