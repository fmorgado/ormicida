library test.ormicida.orm._definitions;

import 'package:ormicida/orm/schema.dart';

/////////////////////////////////////////////////////////////////////////////
////  Simple1 Dynamic  //////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

Map createDynamicSimple1() => {
  's1': false,
  's2': 0,
  's3': ''
};

const SIMPLE_1_DYNAMIC = const IsObject(const <MapField>[
  const MapField('s1', const IsBool()),
  const MapField('s2', const IsInt()),
  const MapField('s3', const IsString())
]);

/////////////////////////////////////////////////////////////////////////////
////  Simple1 Class  ////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

class Simple1 {
  bool    s1;
  int     s2;
  String  s3;
  
  Simple1({this.s1: false, this.s2: 0, this.s3: ''});
}

final SIMPLE_1_CLASS = new IsObject.mutable(<ClassField>[
  new ClassField('s1', const IsBool(),
      (Simple1 target) => target.s1,
      (Simple1 target, bool value) { target.s1 = value; }),
  new ClassField('s2', const IsInt(),
      (Simple1 target) => target.s2,
      (Simple1 target, int value) { target.s2 = value; }),
  new ClassField('s3', const IsString(),
      (Simple1 target) => target.s3,
      (Simple1 target, String value) { target.s3 = value; }),
], () => new Simple1());

/////////////////////////////////////////////////////////////////////////////
////  Simple2 Dynamic  //////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

Map createDynamicSimple2() => {
  'x': 0,
  'y': 0
};

const SIMPLE_2_DYNAMIC = const IsObject(const <MapField>[
  const MapField('x', const IsNum()),
  const MapField('y', const IsNum())
]);

/////////////////////////////////////////////////////////////////////////////
////  Simple2 Class  ////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

class Simple2 {
  num x;
  num y;
  
  Simple2({this.x: 0, this.y: 0});
}

final SIMPLE_2_CLASS = new IsObject.mutable(<ClassField>[
  new ClassField('x', const IsNum(),
      (Simple2 target) => target.x,
      (Simple2 target, num value) { target.x = value; }),
  new ClassField('y', const IsNum(),
      (Simple2 target) => target.y,
      (Simple2 target, num value) { target.y = value; }),
], () => new Simple2());

/////////////////////////////////////////////////////////////////////////////
////  Complex Dynamic  //////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

Map createDynamicComplex() => {
  'c1': false,
  'c2': 0,
  'c3': [0, 1, 2, 3, 4],
  'c4': createDynamicSimple1(),
  'c5': createDynamicSimple2(),
  'c6': [createDynamicSimple1(), createDynamicSimple2(), createDynamicSimple1(),
         createDynamicSimple2(), createDynamicSimple1(), createDynamicSimple2()]
};

const COMPLEX_DYNAMIC = const IsObject(const <MapField>[
  const MapField('c1', const IsBool()),
  const MapField('c2', const IsInt()),
  const MapField('c3', const IsList(schema: const IsInt())),
  const MapField('c4', SIMPLE_1_DYNAMIC),
  const MapField('c5', SIMPLE_2_DYNAMIC),
  const MapField('c6', const IsUnion(const [
    const SchemaAlias('test.simple1', null, SIMPLE_1_DYNAMIC),
    const SchemaAlias('test.simple2', null, SIMPLE_2_DYNAMIC)
  ])),
]);

/////////////////////////////////////////////////////////////////////////////
////  Complex Class  ////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

class Complex {
  bool      c1;
  int       c2;
  List<int> c3;
  Simple1   c4;
  Simple2   c5;
  List      c6;
  
  Complex({this.c1: false, this.c2: 0, this.c3, this.c4, this.c5, this.c6});
}

final COMPLEX_CLASS = new IsObject.mutable(<ClassField>[
  new ClassField('c1', const IsBool(),
      (Complex target) => target.c1,
      (Complex target, bool value) { target.c1 = value; }),
  new ClassField('c2', const IsInt(),
      (Complex target) => target.c2,
      (Complex target, int value) { target.c2 = value; }),
  new ClassField('c3', const IsList(schema: const IsInt()),
      (Complex target) => target.c3,
      (Complex target, List<int> value) { target.c3 = value; }),
  new ClassField('c4', SIMPLE_1_DYNAMIC,
      (Complex target) => target.c4,
      (Complex target, Simple1 value) { target.c4 = value; }),
  new ClassField('c5', SIMPLE_2_DYNAMIC,
      (Complex target) => target.c5,
      (Complex target, Simple2 value) { target.c5 = value; }),
  new ClassField('c6', new IsList(schema: new IsUnion([
          new SchemaAlias('test.simple1', Simple1, SIMPLE_1_CLASS),
          new SchemaAlias('test.simple2', Simple2, SIMPLE_2_CLASS)
        ])),
      (Complex target) => target.c6,
      (Complex target, List value) { target.c6 = value; }),
], () => new Complex());
