import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mixology2/pantallas/login.dart';

class Registrar extends StatefulWidget {
  const Registrar({Key? key}) : super(key: key);

  @override
  State<Registrar> createState() {
    return _RegistrarState();
  }
}

class _RegistrarState extends State<Registrar> {
  late String email, password;

  final formKey = GlobalKey<FormState>();
  String error = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF22314F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Container(
          width: 320,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Color(0xFF1B2A47),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Registrar Usuario",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 24),
              Offstage(
                offstage: error.isEmpty,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    error,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ),
              formulario(),
              SizedBox(height: 24),
              buttonRegistrar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget formulario() {
    return Form(
      key: formKey,
      child: Column(
        children: [
          buildEmail(),
          SizedBox(height: 16),
          buildPassword(),
        ],
      ),
    );
  }

  Widget buildEmail() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Email',
        labelStyle: TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      ),
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: Colors.white),
      onSaved: (String? value) {
        email = value!;
      },
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter an email';
        }
        return null;
      },
    );
  }

  Widget buildPassword() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      ),
      obscureText: true,
      style: TextStyle(color: Colors.white),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter a password';
        }
        return null;
      },
      onSaved: (String? value) {
        password = value!;
      },
    );
  }

  Widget buttonRegistrar() {
    return FractionallySizedBox(
      widthFactor: 0.8,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 15),
          backgroundColor: Color(0xFF00E6FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () async {
          if (formKey.currentState!.validate()) {
            formKey.currentState!.save();
            UserCredential? credenciales = await registrar(email, password);
            if (credenciales != null && credenciales.user != null) {
              if (!credenciales.user!.emailVerified) {
                await credenciales.user!.sendEmailVerification();
              }
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Login()),
                    (Route<dynamic> route) => false,
              );
            }
          }
        },
        child: Text(
          "Registrar",
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Future<UserCredential?> registrar(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'email-already-in-use') {
        errorMessage = "El correo ya está en uso";
      } else if (e.code == 'weak-password') {
        errorMessage = "Contraseña muy débil";
      } else {
        errorMessage = "Error de inicialización";
      }
      setState(() {
        error = errorMessage;
      });
      return null;
    }
  }
}
