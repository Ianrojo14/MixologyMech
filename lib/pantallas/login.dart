import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mixology2/pantallas/home.dart';
import 'package:mixology2/pantallas/registrar.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
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
      backgroundColor: Color(0xFF2C3E50), // Fondo similar al de la imagen
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Color(0xFF34495E), // Fondo del formulario
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Iniciar sesion",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
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
                const SizedBox(height: 20),
                buttonLogin(),
                const SizedBox(height: 10),
                registrarse(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget registrarse() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "¿No tienes cuenta?",
          style: TextStyle(color: Colors.white),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Registrar()));
          },
          child: Text(
            "Registrate",
            style: TextStyle(
              color: Colors.purpleAccent,
              decoration: TextDecoration.underline,
            ),
          ),
        )
      ],
    );
  }

  Widget formulario() {
    return Form(
      key: formKey,
      child: Column(
        children: [
          buildEmail(),
          const SizedBox(height: 20),
          buildPassword(),
        ],
      ),
    );
  }

  Widget buildEmail() {
    return TextFormField(
      style: TextStyle(color: Colors.white), // Cambia el color del texto
      decoration: InputDecoration(
        labelText: 'EMAIL',
        labelStyle: TextStyle(color: Colors.white), // Cambia el color del label
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.cyan),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
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
      style: TextStyle(color: Colors.white), // Cambia el color del texto
      decoration: InputDecoration(
        labelText: 'PASSWORD',
        labelStyle: TextStyle(color: Colors.white), // Cambia el color del label
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.cyan),
        ),
      ),
      obscureText: true,
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

  Widget buttonLogin() {
    return FractionallySizedBox(
      widthFactor: 0.8,
      child: ElevatedButton(
        onPressed: () async {
          if (formKey.currentState!.validate()) {
            formKey.currentState!.save();
            UserCredential? credenciales = await login(email, password);
            if (credenciales != null) {
              if (credenciales.user != null) {
                if (credenciales.user!.emailVerified) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                          (route) => false);
                } else {
                  setState(() {
                    error =
                    "Por favor verifique su correo electrónico para activar su cuenta";
                  });
                }
              }
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF00BCD4), // Color del botón          padding: EdgeInsets.symmetric(vertical: 14), // Tamaño del botón
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          "Login",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Future<UserCredential?> login(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = "Usuario no encontrado";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Contraseña incorrecta";
      } else {
        errorMessage =
        "Error de inicialización"; // Considerar mejorar este mensaje
      }
      setState(() {
        error = errorMessage;
      });
      return null;
    }
  }
}
