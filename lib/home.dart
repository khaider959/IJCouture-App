import 'dart:core';
import 'dart:ffi';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'IJ Couture'),

    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late File? imageFile=null;
  String dressname='';
  String color='';
  String size='';
  String description='';
  String price='';
  String clothtype='';
  String type='';
  String gender='';
  List<String> imageUrls=[];
  var infopics=[];
  int current=0;
  List<String> favlist=[];
  var bookinginfo=[];

  @override
  void initState() {
    // TODO: implement initState
    getfemaleimages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.female)),
                Tab(icon: Icon(Icons.male)),
                Tab(icon: Icon(Icons.star)),
              ],
            ),
            title: Text('IJ Couture'),
            centerTitle: true,
            backgroundColor: Colors.purpleAccent,
          ),
          drawer: Drawer(
              child: new ListView(
                children: <Widget>[
                  new UserAccountsDrawerHeader(
                    accountName: Text('For queries email:'),
                    accountEmail: Text('khaider959@gmail.com'),
                    currentAccountPicture: GestureDetector(
                      child: new ClipOval(
                          child: Image.asset(
                            'assets/images/ij.PNG',
                            fit: BoxFit.cover,
                            width: 100.0,
                            height: 100.0,
                          )
                      ),
                    ),
                    decoration: new BoxDecoration(
                        color: Colors.purpleAccent
                    ),
                  ),
                  TextButton(
                      onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => adminpage()),
                        );
                      },
                      child: Text('For admin use'))
                ],
              )
          ),
          body: TabBarView(
            children: [
              happy(),
              femalepics(),
              favpics(),
            ],
          ),
        ),
      ),
    );
  }

  Widget happy() {
    return
      GridView.extent(
        maxCrossAxisExtent: 200,
        children: _buildGridTiles(imageUrls.length),
      );
  }
  List<Widget> _buildGridTiles(numofimages){
    List<Container> contain = new List<Container>.generate(numofimages, (index) {
      final imagename = index<9?'assets/images/0${index}.PNG':'assets/images/0${index}.PNG';

      return new Container(
        child: new Image.network(imageUrls[index]),
      );
      current=index;
    });
    return contain;
  }

  Future<void> getprefimage() async {
    SharedPreferences imageref = await SharedPreferences.getInstance();
    List<String> templist=[];
    for (var i=0; i<imageUrls.length; i++){
      if (imageref.getString(imageUrls[i])!=null){
        String? name=imageref.getString(imageUrls[i]);
        templist.add(name!);
      }
    }
    setState(() {
      favlist=templist;
    });

  }

  Future<void> getfemaleimages() async {
    dynamic femalepics= FirebaseFirestore.instance.collection("Product").orderBy("CreatedAt").where("Gender",isEqualTo:"Female").where("Avaialable",isEqualTo:true).get();
    print(femalepics);
    QuerySnapshot femaleimages= await FirebaseFirestore.instance.collection("Product").orderBy("CreatedAt",descending:true).where("Gender",isEqualTo:"Female").get();
    for (var doc in femaleimages.docs){
      imageUrls.add(doc["Image"]);
    }
    setState(() {
      imageUrls;
    });
    print(imageUrls);
  }

  Future<void> getinfo(String URL) async {
    dynamic picinfo= FirebaseFirestore.instance.collection("Product").orderBy("CreatedAt").where("Gender",isEqualTo:"Female").where("Avaialable",isEqualTo:true).get();

    var picinform= await FirebaseFirestore.instance.collection("Product").where("Image",isEqualTo:URL).get();

    for (var doc in picinform.docs){
      infopics.add(doc["Description"]); //0
      infopics.add(doc["Price"]); //1
      infopics.add(doc["Size"]); //2
      infopics.add(doc["Type"]); //3
      break;
    }
  }

  Future<void> getbookinfo(String URL) async {
    dynamic picinfo= FirebaseFirestore.instance.collection("Product").orderBy("CreatedAt").where("Gender",isEqualTo:"Female").where("Avaialable",isEqualTo:true).get();

    var info= await FirebaseFirestore.instance.collection("Bookings").where("Image",isEqualTo:URL).get();

    for (var doc in info.docs){
      bookinginfo.add(doc["User name"]); //0
      bookinginfo.add(doc["Number"]); //1
      bookinginfo.add(doc["Email"]); //2
      bookinginfo.add(doc["Appointment date"]); //3
    }


  }



  Widget femalepics(){
    return
        Scaffold(
          body: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
              ),
              itemCount: imageUrls.length,
              itemBuilder: (context, index){
                return PostTile(imageUrls[index]);
              },
        )
        );
  }

  Widget favpics(){
    return
    FutureBuilder(
        future: this.getprefimage(),
    builder: (context, snapshot){
    return
      Scaffold(
        body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
          ),
        itemCount: favlist.length,
          itemBuilder: (context, index){
          return PostTile(favlist[index]);
          },
        )
      );
    });
  }
}

class PostTile extends StatefulWidget {
  String mediaUrl;
  PostTile(this.mediaUrl);

  @override
  _PostTileState createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  final org =new _MyHomePageState();
  String desc='';
  String P = '';
  String S = '';
  String ctype='';

  Future<void> picdetails() async {
    await org.getinfo(widget.mediaUrl);
    var descript = await org.infopics;
    if (descript != null) {
      desc = descript[0];
      P = descript[1];
      S = descript[2];
      ctype = descript[3];
    }
  }
  Future<void> addtoSF(String picurl) async{

    SharedPreferences imageref = await SharedPreferences.getInstance();
    if (imageref.getString(picurl)==null){
    imageref.setString(picurl, picurl);
    }
    else{
      print("already in Sharedpreferences");
    }
  }

  Future<void> removeSF(String picurl) async{
    SharedPreferences imageref = await SharedPreferences.getInstance();
    if(imageref.get(picurl)!=null){
      imageref.remove(picurl);
    }
    else
      {
        print("image does not exist");
      }
  }



  @override
  Widget build(BuildContext context) {
    return
        GestureDetector(
              child: Image.network(widget.mediaUrl),
        onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (BuildContext context) {
                      return
                      FutureBuilder(
                        future: picdetails(),
                        builder: (context, snapshot){
                        return
                        Scaffold(
                        body: GestureDetector(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                color: Colors.purpleAccent,
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(height:15),
                                    Text(
                                      'IJ Couture',
                                      textAlign: TextAlign.center,
                                      semanticsLabel: 'IJ Couture',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                height: 50,
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width,
                              ),
                              Container(
                                height: 500,
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width,
                                child: Hero(
                                  tag: 'imageHero',
                                  child: Image.network(
                                    widget.mediaUrl,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  color: Colors.purpleAccent,
                                  height: MediaQuery
                                      .of(context)
                                      .size
                                      .height,
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width,
                                  child: Row(
                                    children: <Widget>[
                                      SizedBox(
                                      width: 40,
                                  ),
                                      Expanded(
                                        child: Text('$desc',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                          child: Text(
                                              '   Rs.$P',
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                              )
                                          )),
                                      Expanded(
                                          child: Text(
                                              '   Size: $S',
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                              )
                                          )),
                                      Expanded(
                                          child: IconButton(
                                            icon: Icon(Icons.bookmark
                                            ),
                                            onPressed: () => {
                                              addtoSF(widget.mediaUrl)
                                            },
                                          )
                                      ),
                                      Expanded(
                                          child:IconButton(
                                              icon: Icon(Icons.bookmark_remove),
                                              onPressed: () =>{
                                                removeSF(widget.mediaUrl)
                                              }
                                          )
                                      ),
                                      Expanded(
                                        child: FloatingActionButton(
                                          child: Text('Book this dress',
                                          textAlign: TextAlign.center,),
                                          onPressed: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(builder: (context) => Bookingpage(widget.mediaUrl)),
                                            );
                                          },
                                        )
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),

                      );
        },);
                    }));
          }
  );
  }
}

class Bookingpage extends StatefulWidget {

  String image;
  Bookingpage(this.image);

  @override
  _Bookingpage createState() => _Bookingpage(image);
}
class _Bookingpage extends State<Bookingpage> {
  String image;
  String name='';
  String number='';
  String email='';
  String appdate='';
  _Bookingpage(this.image);

  Future <void> bookinginfo() async{
    FirebaseFirestore.instance.collection('Bookings').add({
      'User name':name,
      'Number':number,
      'Email':email,
      'Appointment date':appdate,
      'Image':image,
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IJ Couture'),
        centerTitle: true,
        backgroundColor: Colors.purpleAccent,

      ),
      body:
      Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/Capture.PNG'),
              fit: BoxFit.fill
            )
          ),
          child: Center(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height:30
                ),
                Text('Enter booking information',textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  decoration: TextDecoration.underline
                )),
                SizedBox(height:30),
                Expanded(
                  child: TextField(
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: 'Name',
                      hintStyle: TextStyle(
                        color: Colors.white,
                      ),
                      enabledBorder:  OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white,width: 1.0),
                        borderRadius: BorderRadius.circular(1.0),
                      ),
                    ),
                    onChanged: ((value) {
                      setState(() {
                        name = value;
                      });
                    }),
                  ),
                ),
                Expanded(
                  child: TextField(
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: 'Number',
                      hintStyle: TextStyle(
                        color: Colors.white,
                      ),
                      enabledBorder:  OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white,width: 1.0),
                        borderRadius: BorderRadius.circular(1.0),
                      ),
                    ),
                    onChanged: ((value) {
                      setState(() {
                        number = value;
                      });
                    }),
                  ),
                ),
                Expanded(
                  child: TextField(
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(
                        color: Colors.white,
                      ),
                      enabledBorder:  OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white,width: 1.0),
                        borderRadius: BorderRadius.circular(1.0),
                      ),
                    ),
                    onChanged: ((value) {
                      setState(() {
                        email = value;
                      });
                    }),
                  ),
                ),
                Expanded(
                  child: TextField(
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: 'Set date for your appointment',
                      hintStyle: TextStyle(
                        color: Colors.white,
                      ),
                      enabledBorder:  OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white,width: 1.0),
                        borderRadius: BorderRadius.circular(1.0),
                      ),
                    ),
                    onChanged: ((value) {
                      setState(() {
                        appdate = value;
                      });
                    }),
                  ),
                ),
                ElevatedButton(
                    onPressed: (){
                      bookinginfo();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MyApp()),
                      );
                    },
                    child: Text('Book',
                    style: TextStyle(
                     fontSize: 21,
                     color: Colors.white
                    ),
                      textAlign: TextAlign.center,
                    ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.purpleAccent),
                    padding: MaterialStateProperty.all(EdgeInsets.fromLTRB(40, 10, 40, 10))
                  ),
                ),
                SizedBox(height:10)
              ]
            ),
          ),
        ),
    );
  }
}

class adminpage extends StatefulWidget{
  @override
  _adminpage createState() => _adminpage();
}

class _adminpage extends State<adminpage>{
  late String username;
  late String password;
  void verify(String username,String password){
    if (username=='ismajawad' && password=='ijcoutureapp'){
      print('signed in');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => admininfo()),
      );
    }
    else{
      showDialog(context: context, builder:(BuildContext context){
        return
        AlertDialog(
          title: Text('Incorrect username or password',
          style: TextStyle(
            fontSize: 30,
          ),
            textAlign: TextAlign.center,
          ),
        );
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return
        Scaffold(
          appBar: AppBar(
            title: Text('IJ Couture',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20
            )),
            centerTitle: true,
            backgroundColor: Colors.purpleAccent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back,color:Colors.white),
              onPressed: (){
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp()),
                );
              },
            ),
          ),
          body: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/Capture.PNG'),
                      fit: BoxFit.fill
                  )
              ),
            child:
            Column(
              children: <Widget>[
                SizedBox(height:200),
                Expanded(
                  child: TextField(
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: 'Enter Username',
                      hintStyle: TextStyle(
                        color: Colors.white,
                      ),
                      enabledBorder:  OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white,width: 1.0),
                        borderRadius: BorderRadius.circular(1.0),
                      ),
                    ),
                    onChanged: ((value) {
                      setState(() {
                        username = value;
                      });
                    }),
                  ),
                ),
                Expanded(
                  child: TextField(
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: 'Enter password',
                      hintStyle: TextStyle(
                        color: Colors.white,
                      ),
                      enabledBorder:  OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white,width: 1.0),
                        borderRadius: BorderRadius.circular(1.0),
                      ),
                    ),
                    onChanged: ((value) {
                      setState(() {
                        password = value;
                      });
                    }),
                  ),
                ),
                SizedBox(height:20),
                ElevatedButton(
                  onPressed: (){
                    verify(username, password);
                  },
                  child: Text('Submit',
                    style: TextStyle(
                        fontSize: 21,
                        color: Colors.white
                    ),
                    textAlign: TextAlign.center,
                  ),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.purpleAccent),
                      padding: MaterialStateProperty.all(EdgeInsets.fromLTRB(40, 10, 40, 10))
                  ),
                ),
                SizedBox(height: 100,),
              ],
            )
          )
        );
  }
}

class admininfo extends StatefulWidget{

  @override
  _admininfo createState() => _admininfo();
}

class _admininfo extends State<admininfo>{
  late File? imageFile=null;
  String dressname='';
  String color='';
  String size='';
  String description='';
  String price='';
  String clothtype='';
  String type='';
  String gender='';
  List<String> imageUrls=[];
  var infopics=[];
  _getFromGallery() async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  _getFromCamera() async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  void imageuploader(File inputimageFile) {
    String imagename = DateTime.now().millisecondsSinceEpoch.toString();
    final Reference storageReference =
    FirebaseStorage.instance.ref().child(imagename);
    final UploadTask uploadTask = storageReference.putFile(inputimageFile);
    uploadTask.then((TaskSnapshot taskSnapshot) {
      taskSnapshot.ref.getDownloadURL().then((imageUrl) {
        //save info to firestore
        _saveData(imageUrl);
      });
    }).catchError((error) {
      Fluttertoast.showToast(
        msg: error.toString(),
      );
    });
  }

  Future<void> _saveData(String imageUrl) async {
    print('save date is working');
    FirebaseFirestore.instance.collection('Product').add({
      'Image': imageUrl,
      'Name': dressname,
      'Size': size ,
      'Color': color,
      'Description': description,
      'Type': type,
      'Cloth': clothtype,
      'Price': price,
      'Gender': gender,
      'Available': true,
      'CreatedAt': DateTime.now(),
    });
  }
  Future<void> getbookingimages() async {
    dynamic femalepics= FirebaseFirestore.instance.collection("Product").orderBy("CreatedAt").where("Gender",isEqualTo:"Female").where("Avaialable",isEqualTo:true).get();
    print(femalepics);
    QuerySnapshot femaleimages= await FirebaseFirestore.instance.collection("Bookings").get();
    for (var doc in femaleimages.docs){
      imageUrls.add(doc["Image"]);
    }
    setState(() {
      imageUrls;
    });
    print(imageUrls);
  }

  @override
  void initState() {
    // TODO: implement initState
    getbookingimages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return
        Scaffold(
          appBar: AppBar(
            title: Text('IJ couture',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),

            backgroundColor: Colors.purpleAccent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back,color:Colors.white),
            onPressed: (){
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyApp()),
              );
            },
            ),
          ),
          body: Center(
            child: imageFile == null ? Container(
              constraints: BoxConstraints.expand(),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/00.PNG'),
                      fit: BoxFit.cover)
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 80),
                    child: ElevatedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),

                        ),
                        backgroundColor: Colors.pink,
                      ),
                      onPressed: () {
                        _getFromCamera();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                                'Use camera',
                                style: TextStyle(
                                    color: Colors.purple,
                                    fontSize: 20.0,
                                    letterSpacing: -0.7,
                                    fontFamily: 'OpenSansCondensed-Light'
                                )
                            ),
                            SizedBox(width: 5),
                            Icon(Icons.camera_alt_outlined,
                              color: Colors.purple,)
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 50),
                    child: ElevatedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),

                        ),
                        backgroundColor: Colors.pink,
                      ),
                      onPressed: () {
                        _getFromGallery();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                                'Upload from device',
                                style: TextStyle(
                                    color: Colors.purple,
                                    fontSize: 20.0,
                                    letterSpacing: -0.7,
                                    fontFamily: 'OpenSansCondensed-Light'
                                )
                            ),
                            SizedBox(width: 5),
                            Icon(Icons.file_upload,
                                color: Colors.purple),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40,),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 50),
                    child: ElevatedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),

                        ),
                        backgroundColor: Colors.pink,
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => bookpics()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                                'Check Bookings',
                                style: TextStyle(
                                    color: Colors.purple,
                                    fontSize: 20.0,
                                    letterSpacing: -0.7,
                                    fontFamily: 'OpenSansCondensed-Light'
                                )
                            ),
                            SizedBox(width: 5),
                            Icon(Icons.file_upload,
                                color: Colors.purple),
                          ],
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            )
                : Container(
              constraints: BoxConstraints.expand(),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/01.PNG'),
                      fit: BoxFit.cover)
              ),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        child: Image.file(
                          imageFile!,
                          fit: BoxFit.cover,
                          height: 200,
                          width: 200,
                        )
                    ),
                  ),
                  Expanded(child:
                  TextField(
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: 'Enter Dress Name',
                      hintStyle: TextStyle(
                        color: Colors.white,
                      ),
                      enabledBorder:  UnderlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white,width: 1.0),
                        borderRadius: BorderRadius.circular(1.0),
                      ),
                    ),
                    onChanged: ((value) {
                      setState(() {
                        dressname = value;
                      });
                    }),
                  ),
                  ),
                  Expanded(
                    child: TextField(
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: 'Enter Dress Color',
                        hintStyle: TextStyle(
                          color: Colors.white,
                        ),
                        enabledBorder:  UnderlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white,width: 1.0),
                          borderRadius: BorderRadius.circular(1.0),
                        ),
                      ),
                      onChanged: ((value) {
                        setState(() {
                          color = value;
                        });
                      }),
                    ),
                  ),
                  Expanded(child:
                  TextField(
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: 'Enter Dress Description',
                      hintStyle: TextStyle(
                        color: Colors.white,
                      ),
                      enabledBorder:  UnderlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white,width: 1.0),
                        borderRadius: BorderRadius.circular(1.0),
                      ),
                    ),
                    onChanged: ((value) {
                      setState(() {
                        description = value;
                      });
                    }),
                  ),
                  ),
                  Expanded(child:
                  TextField(
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: 'Enter Dress Size',
                      hintStyle: TextStyle(
                        color: Colors.white,
                      ),
                      enabledBorder:  UnderlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white,width: 1.0),
                        borderRadius: BorderRadius.circular(1.0),
                      ),
                    ),
                    onChanged: ((value) {
                      setState(() {
                        size = value;
                      });
                    }),
                  ),
                  ),

                  Expanded(
                    child: TextField(
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: 'Enter Dress Price',
                        hintStyle: TextStyle(
                          color: Colors.white,
                        ),
                        enabledBorder:  UnderlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white,width: 1.0),
                          borderRadius: BorderRadius.circular(1.0),
                        ),
                      ),
                      onChanged: ((value) {
                        setState(() {
                          price = value;
                        });
                      }),
                    ),
                  ),

                  Expanded(
                    child: TextField(
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: 'Enter Dress Cloth Type',
                        hintStyle: TextStyle(
                          color: Colors.white,
                        ),
                        enabledBorder:  UnderlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white,width: 1.0),
                          borderRadius: BorderRadius.circular(1.0),
                        ),
                      ),
                      onChanged: ((value) {
                        setState(() {
                          clothtype = value;
                        });
                      }),
                    ),
                  ),

                  Expanded(
                    child: TextField(
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: 'Enter Dress Formal or Party Wear',
                        hintStyle: TextStyle(
                          color: Colors.white,
                        ),
                        enabledBorder:  UnderlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white,width: 1.0),
                          borderRadius: BorderRadius.circular(1.0),
                        ),
                      ),
                      onChanged: ((value) {
                        setState(() {
                          type = value;
                        });
                      }),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: 'Male or Female',
                        hintStyle: TextStyle(
                          color: Colors.white,
                        ),
                        enabledBorder:  UnderlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white,width: 1.0),
                          borderRadius: BorderRadius.circular(1.0),
                        ),
                      ),
                      onChanged: ((value) {
                        setState(() {
                          gender = value;
                        });
                      }),
                    ),
                  ),
                  FloatingActionButton(
                    child: Icon(Icons.backup_outlined),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    onPressed: () =>
                    {
                      imageuploader(imageFile!),
                      Future.delayed(Duration(seconds: 5), () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => admininfo())
                        );
                      }),

                    },
                  ),
                ],
              ),
            ),
          ),
        );
  }
  Widget bookpics(){
    return
      Scaffold(
          appBar: AppBar(
            title: Text('Bookings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            backgroundColor: Colors.purpleAccent,
          ),
          body: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
            ),
            itemCount: imageUrls.length,
            itemBuilder: (context, index){
              return Booktile(imageUrls[index]);
            },
          )
      );
  }
}


class Booktile extends StatefulWidget {
  String mediaUrl;
  Booktile(this.mediaUrl);

  @override
  _Booktile createState() => _Booktile();
}

class _Booktile extends State<Booktile> {
  final org =new _MyHomePageState();
  String name='';
  String number = '';
  String email = '';
  String appdate='';

  Future<void> bookdetails() async {
    await org.getbookinfo(widget.mediaUrl);
    var descript = await org.bookinginfo;
    if (descript != null) {
      name = descript[0];
      number = descript[1];
      email = descript[2];
      appdate = descript[3];
    }
  }

  Future<void>deltebooking(String url) async{
    var collection = FirebaseFirestore.instance.collection('Bookings');
    var snapshot = await collection.where('Image', isEqualTo:url).get();
    await snapshot.docs.first.reference.delete();

  }
  @override
  Widget build(BuildContext context) {
    return
      GestureDetector(
          child: Image.network(widget.mediaUrl),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (BuildContext context) {
                      return
                        FutureBuilder(
                          future: bookdetails(),
                          builder: (context, snapshot){
                            return
                              Scaffold(
                                body: GestureDetector(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        color: Colors.purpleAccent,
                                        child: Column(
                                          children: <Widget>[
                                            SizedBox(height:15),
                                            Text(
                                              'IJ Couture',
                                              textAlign: TextAlign.center,
                                              semanticsLabel: 'IJ Couture',
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        height: 50,
                                        width: MediaQuery
                                            .of(context)
                                            .size
                                            .width,
                                      ),
                                      Container(
                                        height: 500,
                                        width: MediaQuery
                                            .of(context)
                                            .size
                                            .width,
                                        child: Hero(
                                          tag: 'imageHero',
                                          child: Image.network(
                                            widget.mediaUrl,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          color: Colors.purpleAccent,
                                          height: MediaQuery
                                              .of(context)
                                              .size
                                              .height,
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width,
                                          child: Row(
                                            children: <Widget>[
                                              SizedBox(
                                                width: 40,
                                              ),
                                              Expanded(
                                                child: Text('$name',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                  child: Text(
                                                      '  $number',
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.white,
                                                      )
                                                  )),
                                              Expanded(
                                                  child: Text(
                                                      '   $email',
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.white,
                                                      )
                                                  )),
                                              Expanded(
                                                  child: Text(
                                                      '   $appdate',
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.white,
                                                      )
                                                  )),
                                              Expanded(
                                                  child: FloatingActionButton(
                                                    child: Text('Remove booking',
                                                      textAlign: TextAlign.center,),
                                                    onPressed: () {
                                                      deltebooking(widget.mediaUrl);

                                                      Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(builder: (context) => admininfo()),
                                                      );
                                                    },
                                                  )
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                ),

                              );
                          },);
                    }));
          }
      );
  }

}
