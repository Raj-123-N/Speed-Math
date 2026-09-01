import 'dart:async';
import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../models/practice_models.dart';
import '../services/practice_question_engine.dart';

class PracticeSessionScreen extends StatefulWidget {
  const PracticeSessionScreen({super.key, required this.config});
  final PracticeConfig config;
  @override State<PracticeSessionScreen> createState() => _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends State<PracticeSessionScreen> {
  final _engine = PracticeQuestionEngine(), _answer = TextEditingController(), _focus = FocusNode();
  late PracticeQuestion _question;
  late DateTime _started;
  Timer? _timer;
  int _index = 0, _correct = 0, _wrong = 0, _remaining = 0;
  bool _locked = false, _finishing = false;

  @override void initState() {
    super.initState();
    _started = DateTime.now(); _remaining = widget.config.timeLimitSeconds; _question = _engine.next(widget.config);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  void _tick() {
    if (!mounted || _finishing) return;
    if (widget.config.timeMode == PracticeTimeMode.limit && _remaining <= 1) { _remaining = 0; _finish(); }
    else { setState(() { if (widget.config.timeMode == PracticeTimeMode.limit) _remaining--; }); }
  }

  void _submit(String raw) {
    if (_locked || _finishing || raw.trim().isEmpty) return;
    final normalized = raw.trim().replaceAll(' ', '').toLowerCase();
    final expected = _question.answer.trim().replaceAll(' ', '').toLowerCase();
    final ok = normalized == expected;
    setState(() { _locked = true; if (ok) _correct++; else _wrong++; });
    Future.delayed(Duration(milliseconds: widget.config.quickSubmit ? 90 : 240), () {
      if (!mounted || _finishing) return;
      if (_index + 1 >= widget.config.questions) { _finish(); return; }
      setState(() { _index++; _question = _engine.next(widget.config); _answer.clear(); _locked = false; });
      _focus.requestFocus();
    });
  }

  void _finish() {
    if (!mounted || _finishing) return;
    _finishing = true; _timer?.cancel();
    final total = _index + (_locked ? 1 : 0);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PracticeResultScreen(result: PracticeResult(total: total, correct: _correct, wrong: _wrong, elapsed: DateTime.now().difference(_started)), categoryName: widget.config.category.name)));
  }

  bool get _numericInput => switch (widget.config.category.operation) {
    MathOperation.series || MathOperation.linearEquation || MathOperation.quadraticEquation || MathOperation.cubicEquation => false,
    MathOperation.bodmas || MathOperation.simplification || MathOperation.powers || MathOperation.exponents => true,
    _ => true,
  };

  @override void dispose() { _timer?.cancel(); _answer.dispose(); _focus.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark, accent = practiceSectionColor(widget.config.category);
    final time = widget.config.timeMode == PracticeTimeMode.stopwatch ? DateTime.now().difference(_started) : Duration(seconds: _remaining);
    return Scaffold(
      backgroundColor: dark ? AppColors.backgroundDark : const Color(0xFFF3F5F9),
      appBar: AppBar(backgroundColor: dark ? AppColors.surfaceDark : Colors.white, surfaceTintColor: Colors.transparent, title: Text(widget.config.category.name, style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800)), actions: [IconButton(onPressed: _finish, icon: const Icon(Icons.close_rounded))]),
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16,14,16,8), child: Row(children: [_metric(Icons.timer_outlined, _format(time), accent), const Spacer(), _metric(Icons.help_outline_rounded, '${widget.config.questions - _index} left', accent)])),
        LinearProgressIndicator(value: (_index + 1) / widget.config.questions, minHeight: 4, color: accent, backgroundColor: accent.withValues(alpha:.12)),
        Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(16,26,16,24), children: [
          Center(child: Text('QUESTION ${_index + 1}', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.4, color: accent))), const SizedBox(height: 22),
          Container(padding: const EdgeInsets.symmetric(horizontal:18, vertical:30), decoration: BoxDecoration(color: dark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: accent.withValues(alpha:.25))), child: Center(child: Text(_question.prompt, textAlign: TextAlign.center, style: TextStyle(fontSize:30,fontWeight:FontWeight.w900,color:dark?Colors.white:const Color(0xFF162033))))), const SizedBox(height:24),
          if (widget.config.inputMode == PracticeInputMode.mcq) _buildMcq(accent) else _buildKeyboard(accent,dark),
          const SizedBox(height:18), if (_locked) Center(child: Text(_answer.text.trim().toLowerCase() == _question.answer.trim().toLowerCase() ? 'Correct ✓' : 'Answer: ${_question.answer}', style: TextStyle(fontWeight:FontWeight.w800,color:_answer.text.trim().toLowerCase() == _question.answer.trim().toLowerCase()?Colors.green:Colors.red))),
        ])),
      ])),
    );
  }

  Widget _metric(IconData icon,String text,Color accent)=>Container(padding:const EdgeInsets.symmetric(horizontal:12,vertical:8),decoration:BoxDecoration(color:accent.withValues(alpha:.10),borderRadius:BorderRadius.circular(12)),child:Row(mainAxisSize:MainAxisSize.min,children:[Icon(icon,size:17,color:accent),const SizedBox(width:6),Text(text,style:TextStyle(fontWeight:FontWeight.w900,color:accent))]));
  String _format(Duration d)=>'${d.inMinutes.toString().padLeft(2,'0')}:${(d.inSeconds%60).toString().padLeft(2,'0')}';

  Widget _buildKeyboard(Color accent,bool dark)=>Column(children:[
    TextField(controller:_answer,focusNode:_focus,autofocus:true,keyboardType:_numericInput?const TextInputType.numberWithOptions(decimal:true,signed:true):TextInputType.text,textInputAction:TextInputAction.done,onSubmitted:_submit,onChanged:(v){if(widget.config.autoSubmit&&v.trim().isNotEmpty&&v.trim().replaceAll(' ','').toLowerCase()==_question.answer.replaceAll(' ','').toLowerCase())_submit(v);},decoration:InputDecoration(labelText:_question.inputHint,hintText:_numericInput?'Use your number pad or type here':'Use your full keyboard • letters and symbols supported',prefixIcon:Icon(Icons.keyboard_alt_outlined,color:accent),suffixIcon:IconButton(tooltip:'Quick submit',onPressed:()=>_submit(_answer.text),icon:Icon(Icons.bolt_rounded,color:accent)),filled:true,fillColor:dark?AppColors.cardDark:Colors.white,border:OutlineInputBorder(borderRadius:BorderRadius.circular(16),borderSide:BorderSide(color:accent.withValues(alpha:.3))),focusedBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(16),borderSide:BorderSide(color:accent,width:2))),),
    const SizedBox(height:10),Text(widget.config.autoSubmit?'Auto-submit on exact answer • Bolt = submit now':'Press Enter or tap the bolt to submit',style:TextStyle(fontSize:12,color:dark?Colors.white60:Colors.black54)),
  ]);

  Widget _buildMcq(Color accent)=>Column(children:_question.options.map((option)=>Padding(padding:const EdgeInsets.only(bottom:10),child:SizedBox(width:double.infinity,child:OutlinedButton(onPressed:_locked?null:(){_answer.text=option;_submit(option);},style:OutlinedButton.styleFrom(padding:const EdgeInsets.symmetric(vertical:16),side:BorderSide(color:accent.withValues(alpha:.35)),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(15))),child:Text(option,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w800))))).toList());
}

class PracticeResultScreen extends StatelessWidget {
  const PracticeResultScreen({super.key,required this.result,required this.categoryName});
  final PracticeResult result; final String categoryName;
  @override Widget build(BuildContext context){final dark=Theme.of(context).brightness==Brightness.dark,accent=const Color(0xFFF97316);return Scaffold(backgroundColor:dark?AppColors.backgroundDark:const Color(0xFFF3F5F9),body:SafeArea(child:Center(child:Padding(padding:const EdgeInsets.all(24),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(Icons.emoji_events_rounded,size:72,color:accent),const SizedBox(height:16),Text('Practice complete',style:AppTypography.headlineMedium.copyWith(fontWeight:FontWeight.w900)),const SizedBox(height:6),Text(categoryName,style:TextStyle(color:dark?Colors.white60:Colors.black54)),const SizedBox(height:28),Container(width:double.infinity,padding:const EdgeInsets.all(22),decoration:BoxDecoration(color:dark?AppColors.cardDark:Colors.white,borderRadius:BorderRadius.circular(22)),child:Column(children:[Text('${(result.accuracy*100).round()}%',style:TextStyle(fontSize:42,fontWeight:FontWeight.w900,color:accent)),const Text('Accuracy'),const SizedBox(height:18),Row(mainAxisAlignment:MainAxisAlignment.spaceEvenly,children:[Text('✓ ${result.correct}',style:const TextStyle(fontWeight:FontWeight.w800,color:Colors.green)),Text('✕ ${result.wrong}',style:const TextStyle(fontWeight:FontWeight.w800,color:Colors.red)),Text(_format(result.elapsed),style:const TextStyle(fontWeight:FontWeight.w800))])])),const SizedBox(height:24),FilledButton.icon(onPressed:()=>Navigator.pop(context),icon:const Icon(Icons.arrow_back_rounded),label:const Text('Back to Practice'))]))));}
  String _format(Duration d)=>'${d.inMinutes}m ${d.inSeconds%60}s';
}
