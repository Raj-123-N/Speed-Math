import 'dart:math';
import '../../../core/models/quiz_category.dart';
import '../models/practice_models.dart';

class PracticeQuestionEngine {
  PracticeQuestionEngine({Random? random}) : _random = random ?? Random();
  final Random _random;
  final List<String> _recent = [];

  PracticeQuestion next(PracticeConfig c) {
    var q = _generate(c); var guard = 0;
    while (_recent.contains(q.prompt) && guard++ < 30) q = _generate(c);
    _recent.add(q.prompt); if (_recent.length > 40) _recent.removeAt(0); return q;
  }
  PracticeQuestion _generate(PracticeConfig c) => switch (c.pattern) {
    PracticePattern.arithmetic => _arithmetic(c), PracticePattern.multiplication => _multiply(c), PracticePattern.division => _divide(c),
    PracticePattern.tables => _tables(c), PracticePattern.recall => _recall(c), PracticePattern.generic => _topic(c),
  };
  int _between(int a,int b)=>a+_random.nextInt(max(1,b-a+1));
  int _number(int digits){final d=digits.clamp(1,5).toInt(),lo=d==1?1:pow(10,d-1).toInt(),hi=pow(10,d).toInt()-1;return _between(lo,hi);}
  PracticeQuestion _arithmetic(PracticeConfig c){final n=c.terms.clamp(2,6).toInt(),v=List.generate(n,(_)=>_number(c.rhsDigits));if(c.category.operation==MathOperation.subtraction){v[0]=_number(c.lhsDigits);for(var i=1;i<n;i++)v[i]=min(v[i],max(1,v[0]~/n));return _numeric('${v.join(' − ')} = ?',v[0]-v.skip(1).fold(0,(a,b)=>a+b));}return _numeric('${v.join(' + ')} = ?',v.fold(0,(a,b)=>a+b));}
  PracticeQuestion _multiply(PracticeConfig c){final a=_number(c.lhsDigits),b=_number(c.rhsDigits);return _numeric('$a × $b = ?',a*b);}
  PracticeQuestion _divide(PracticeConfig c){final d=_number(c.rhsDigits),q=_number(c.lhsDigits);return _numeric('${d*q} ÷ $d = ?',q);}
  PracticeQuestion _tables(PracticeConfig c){final a=min(c.tableStart,c.tableEnd).clamp(1,100).toInt(),b=max(c.tableStart,c.tableEnd).clamp(1,100).toInt(),t=_between(a,b),m=_between(1,c.multiplierMax.clamp(1,20).toInt());return _numeric('$t × $m = ?',t*m);}
  PracticeQuestion _recall(PracticeConfig c){final n=_between(c.valueStart.clamp(1,1000),c.valueEnd.clamp(1,1000));switch(c.category.operation){case MathOperation.square:return _numeric('$n² = ?',n*n);case MathOperation.cube:return _numeric('$n³ = ?',n*n*n);case MathOperation.squareRoot:return _numeric('√${n*n} = ?',n);case MathOperation.cubeRoot:return _numeric('∛${n*n*n} = ?',n);case MathOperation.percentage:return _percentage();case MathOperation.fraction:return _fraction();default:return _topic(c);}}
  PracticeQuestion _percentage(){final p=[5,10,20,25,50][_random.nextInt(5)],n=_between(10,100)*10;return _numeric('$p% of $n = ?',n*p/100);}
  PracticeQuestion _fraction(){const p={'1/2':'0.5','1/4':'0.25','3/4':'0.75','3/8':'0.375','5/8':'0.625','7/10':'0.7'};final k=p.keys.elementAt(_random.nextInt(p.length));return PracticeQuestion(prompt:'$k = decimal ?',answer:p[k]!,options:_options(p[k]!),inputHint:'Decimal');}
  PracticeQuestion _topic(PracticeConfig c){switch(c.category.operation){
    case MathOperation.bodmas:return _numeric('$_n + $_m × 2 = ?',_n+_m*2);case MathOperation.simplification:return _numeric('($_n + $_m) × 2 = ?',(_n+_m)*2);case MathOperation.series:return _series();case MathOperation.sequencesPatterns:return _advancedSeries();
    case MathOperation.linearEquation:return _linear();case MathOperation.quadraticEquation:return _quadratic();case MathOperation.cubicEquation:return _numeric('x³ = ${_n*_n*_n}; x = ?',_n);case MathOperation.unitDigit:return _numeric('Unit digit of 2^$_n = ?',_powMod(2,_n,10));case MathOperation.powers:case MathOperation.exponents:return _numeric('$_n² = ?',_n*_n);
    case MathOperation.algebra:return _linear();case MathOperation.trigonometry:return _trig();case MathOperation.diAddition:return _numeric('Data total: $_n + $_m + $_k = ?',_n+_m+_k);case MathOperation.quickRecallWorkout:return _multiply(c);case MathOperation.basicsWorkout:return _arithmetic(c);case MathOperation.mixAdvance:return _series();case MathOperation.miscellaneousMix:return _mixed();
    case MathOperation.numberSystem:return _numberSystem();case MathOperation.placeValue:return _placeValue();case MathOperation.factorsMultiples:return _factors();case MathOperation.divisibility:return _divisibility();case MathOperation.remainders:return _remainders();case MathOperation.averages:return _averages();case MathOperation.ratioProportion:return _ratio();case MathOperation.profitLossDiscount:return _profit();case MathOperation.simpleCompoundInterest:return _interest();case MathOperation.mixtureAlligation:return _mixture();case MathOperation.partnership:return _partnership();case MathOperation.ages:return _ages();
    case MathOperation.timeWork:return _timeWork();case MathOperation.pipesCisterns:return _pipes();case MathOperation.speedDistance:return _speed();case MathOperation.trains:return _trains();case MathOperation.boatsStreams:return _boats();case MathOperation.arithmeticProgression:return _ap();case MathOperation.geometricProgression:return _gp();case MathOperation.polynomials:return _polynomial();case MathOperation.geometryBasics:return _geometry();case MathOperation.mensuration2d:return _m2d();case MathOperation.mensuration3d:return _m3d();case MathOperation.pythagorean:return _pythagorean();
    case MathOperation.permutationCombination:return _pnC();case MathOperation.probability:return _probability();case MathOperation.dataInterpretation:return _data();case MathOperation.statistics:return _statistics();case MathOperation.mentalMultiplication:return _numeric('$_n × 25 = ?',_n*25);case MathOperation.fastDivision:return _numeric('${_n*25} ÷ 25 = ?',_n);default:return _numeric('$_n + $_m = ?',_n+_m);
  }}
  int get _n=>_between(2,30);int get _m=>_between(2,30);int get _k=>_between(2,30);
  PracticeQuestion _series(){final s=_n,d=_between(2,8),v=List.generate(4,(i)=>s+i*d);return _numeric('${v.join(', ')}, ?',v.last+d);}
  PracticeQuestion _advancedSeries(){final s=_between(2,9),v=List.generate(4,(i)=>(s+i)*(s+i));return _numeric('${v.join(', ')}, ?',pow(s+4,2));}
  PracticeQuestion _linear(){final x=_between(1,9),a=_between(2,7),b=_between(1,9);return _numeric('${a}x + $b = ${a*x+b}; x = ?',x,inputHint:'Value of x');}
  PracticeQuestion _quadratic(){final a=_between(1,5),b=_between(1,5);return _numeric('x² − ${a+b}x + ${a*b}=0; smaller x = ?',min(a,b),inputHint:'Value of x');}
  PracticeQuestion _mixed(){final g=<PracticeQuestion Function()>[()=>_series(),()=>_averages(),()=>_ratio(),()=>_profit()];return g[_random.nextInt(g.length)]();}
  PracticeQuestion _numberSystem(){final n=_between(100,999);return _numeric('Digit sum of $n = ?',n.toString().split('').map(int.parse).fold(0,(a,b)=>a+b));}
  PracticeQuestion _placeValue(){final n=_between(1000,99999),p=_between(0,3),v=int.parse(n.toString()[n.toString().length-1-p])*pow(10,p).toInt();return _numeric('Place value of digit ${p+1} from right in $n = ?',v);}
  PracticeQuestion _factors(){final a=_between(6,40),b=_between(6,40),g=_gcd(a,b);return _numeric('HCF of $a and $b = ?',g);}
  PracticeQuestion _divisibility(){final n=_between(100,9999);return _numeric('Is $n divisible by 3? (1=yes,0=no)',n%3==0?1:0);}
  PracticeQuestion _remainders(){final d=_between(3,12),a=_between(2,9),e=_between(2,8);return _numeric('$a^$e mod $d = ?',_powMod(a,e,d));}
  PracticeQuestion _averages(){final n=4+_random.nextInt(3),avg=_between(10,40),delta=_between(1,10);return _numeric('Average of $n values is $avg. Add $delta to one value. New average = ?',avg+delta/n);}
  PracticeQuestion _ratio(){final a=_between(2,8),b=_between(2,8),total=(a+b)*_between(2,10);return _numeric('Ratio $a:$b, total $total. First share = ?',total*a/(a+b));}
  PracticeQuestion _profit(){final cp=_between(100,900),p=[10,20,25,30][_random.nextInt(4)];return _numeric('CP=$cp, profit=$p%. SP = ?',cp*(100+p)/100);}
  PracticeQuestion _interest(){final p=_between(100,900),r=[5,10,20][_random.nextInt(3)],t=_between(1,3);return _numeric('SI on $p at $r% for $t year(s) = ?',p*r*t/100);}
  PracticeQuestion _mixture(){final a=_between(10,30),b=_between(50,90);return _numeric('Equal mix of $a% and $b%. Mean % = ?',(a+b)/2);}
  PracticeQuestion _partnership(){final a=_between(2,9),b=_between(2,9),ta=_between(2,12),tb=_between(2,12);return _numeric('Capital-time ratio: $a×$ta : $b×$tb. First weight = ?',a*ta);}
  PracticeQuestion _ages(){final age=_between(5,30),gap=_between(2,10);return _numeric('B is $age years old and A is $gap years older. A = ?',age+gap);}
  PracticeQuestion _timeWork(){final a=_between(3,12),b=_between(3,12);return _numeric('A takes $a days, B $b days. Combined rate = ?',1/a+1/b);}
  PracticeQuestion _pipes(){final a=_between(2,8),b=_between(5,12);return _numeric('Fill $a h, drain $b h. Net rate = ?',1/a-1/b);}
  PracticeQuestion _speed(){final s=_between(20,80),t=_between(2,6);return _numeric('$s km/h for $t h. Distance = ?',s*t);}
  PracticeQuestion _trains(){final a=_between(50,200),b=_between(50,200),v=_between(10,40);return _numeric('Lengths ${a}m and ${b}m, relative speed ${v}m/s. Time = ?',(a+b)/v);}
  PracticeQuestion _boats(){final d=_between(12,30),u=_between(5,d-1);return _numeric('Downstream $d, upstream $u. Still-water speed = ?',(d+u)/2);}
  PracticeQuestion _ap(){final a=_between(1,10),d=_between(1,8),n=_between(5,15);return _numeric('AP a=$a,d=$d. Term $n = ?',a+(n-1)*d);}
  PracticeQuestion _gp(){final a=_between(1,4),r=_between(2,4),n=_between(3,6);return _numeric('GP a=$a,r=$r. Term $n = ?',a*pow(r,n-1));}
  PracticeQuestion _polynomial(){final r=_between(1,8);return _numeric('For x²−${2*r}x+${r*r}, one root = ?',r);}
  PracticeQuestion _geometry(){final a=_between(30,80),b=_between(20,70);return _numeric('Triangle angles $a° and $b°. Third = ?',180-a-b);}
  PracticeQuestion _m2d(){final r=_between(2,20);return _numeric('Circle r=$r, use π=22/7. Area = ?',22*r*r/7);}
  PracticeQuestion _m3d(){final a=_between(2,10);return _numeric('Cube side=$a. Volume = ?',a*a*a);}
  PracticeQuestion _pythagorean(){final a=_between(3,12),b=_between(3,12);return _numeric('Right triangle legs $a,$b. Hypotenuse = ?',sqrt(a*a+b*b));}
  PracticeQuestion _pnC(){final n=_between(5,9),r=_between(2,3);return _numeric('$n C $r = ?',_fact(n)/(_fact(r)*_fact(n-r)));}
  PracticeQuestion _probability(){final total=_between(5,20),fav=_between(1,total-1),p=_fmt(fav/total);return PracticeQuestion(prompt:'$fav favourable out of $total. Probability = ?',answer:p,options:_options(p),inputHint:'Decimal');}
  PracticeQuestion _data(){final a=_between(100,500),b=_between(100,700);return _numeric('Percentage increase from $a to $b = ?',100*(b-a)/a);}
  PracticeQuestion _statistics(){final a=_between(5,20),b=_between(5,20),c=_between(5,20);return _numeric('Mean of $a,$b,$c = ?',(a+b+c)/3);}
  PracticeQuestion _trig(){const p={'sin 30°':.5,'cos 60°':.5,'sin 90°':1,'cos 0°':1,'tan 45°':1};final k=p.keys.elementAt(_random.nextInt(p.length));return _numeric('$k = ?',p[k]!);}
  PracticeQuestion _numeric(String prompt,num answer,{String inputHint='Answer'}){final a=_fmt(answer);return PracticeQuestion(prompt:prompt,answer:a,options:_options(a),inputHint:inputHint);}
  String _fmt(num v)=>v==v.roundToDouble()?v.round().toString():v.toStringAsFixed(4).replaceFirst(RegExp(r'0+$'),'').replaceFirst(RegExp(r'\.$'),'');
  List<String> _options(String answer){final x=double.tryParse(answer)??0;final set=<String>{answer};for(var i=1;set.length<4;i++)set.add(_fmt(x+(x.abs()<10?i/10:i)));final r=set.toList()..shuffle(_random);return r;}
  int _powMod(int a,int e,int m){var r=1,b=a%m;while(e>0){if(e.isOdd)r=r*b%m;b=b*b%m;e>>=1;}return r;}
  int _gcd(int a,int b){while(b!=0){final t=a%b;a=b;b=t;}return a.abs();}
  int _fact(int n){var r=1;for(var i=2;i<=n;i++)r*=i;return r;}
}
