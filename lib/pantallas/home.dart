import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mixology2/bebidas/bebida_model.dart';
import 'login.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child("bebidas");
  DatabaseReference counterRef = FirebaseDatabase.instance.ref().child("bebidaCounter");

  final TextEditingController _edtCantidadController = TextEditingController();
  final TextEditingController _edtMesaController = TextEditingController();

  List<Bebida> bebidaList = [];
  bool updateBebida = false;
  String selectedDrink = '';
  String? bebidaKey;



  @override
  void initState() {
    super.initState();
    retrieveBebidaData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF22314F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Directorio de Bebidas",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          InkWell(
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Login()),
                    (route) => false,
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.exit_to_app, color: Colors.white),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // Reduced columns for better layout on smaller screens
          shrinkWrap: true,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            drinkButton('Daiquiri', Color(0xFF6C63FF), Icons.local_bar),
            drinkButton('Gin Tonic', Color(0xFF2EC4B6), Icons.local_bar),
            drinkButton('Black Russian', Color(0xFFEF476F), Icons.local_bar),
            drinkButton('Cuba Libre', Color(0xFF8D99AE), Icons.local_bar),
            drinkButton('Margarita', Color(0xFFFFA822), Icons.local_bar),
            drinkButton('Ice Tea', Color(0xFFEE6C4D), Icons.local_bar),
          ],
        ),
      ),
    );
  }

  Widget drinkButton(String name, Color color, IconData icon) {
    return ElevatedButton(
      onPressed: () {
        selectedDrink = name;
        updateBebida = false;
        bebidaKey = null;
        bebidaDialog();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.zero,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void bebidaDialog({String? key}) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Color(0xFF1B2A47),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '¿Desea seleccionar la bebida: $selectedDrink?',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _edtMesaController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Número de mesa',
                    labelStyle: TextStyle(color: Colors.white54),
                    border: OutlineInputBorder(),
                    fillColor: Color(0xFF1B2A47),
                    filled: true,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00E6FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        final mesaNumero = _edtMesaController.text;

                        Map<String, dynamic> data = {
                          "nombre": selectedDrink,
                          "cantidad": "1",
                          "mesa": mesaNumero,
                        };

                        if (updateBebida) {
                          // Actualiza la bebida existente
                          dbRef.child(key!).update(data).then((value) {
                            int index = bebidaList.indexWhere((element) => element.clave == key);
                            bebidaList.removeAt(index);
                            bebidaList.insert(index, Bebida(clave: key, datosBebida: DatosBebida.fromJson(data)));
                            setState(() {});
                            Navigator.of(context).pop();
                          });
                        } else {
                          // Obtén el valor actual del contador
                          DataSnapshot snapshot = await counterRef.get();
                          int counter = (snapshot.value as int?) ?? 0;
                          counter++;

                          // Usa el contador como clave para la nueva bebida
                          String newKey = counter.toString();
                          dbRef.child(newKey).set(data).then((value) {
                            // Actualiza el valor del contador en la base de datos
                            counterRef.set(counter);
                            bebidaList.add(Bebida(clave: newKey, datosBebida: DatosBebida.fromJson(data)));
                            setState(() {});
                          });
                        }
                        Navigator.of(context).pop();
                      },
                      child: const Text("Sí"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFEF476F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Cerrar el diálogo si selecciona "No"
                      },
                      child: const Text("No"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  void retrieveBebidaData() {
    dbRef.onChildAdded.listen((data) {
      final value = Map<String, dynamic>.from(data.snapshot.value as Map);
      DatosBebida datosBebida = DatosBebida.fromJson(value);
      Bebida bebida = Bebida(clave: data.snapshot.key, datosBebida: datosBebida);
      bebidaList.add(bebida);
      setState(() {});
    });

    dbRef.onChildChanged.listen((data) {
      final value = Map<String, dynamic>.from(data.snapshot.value as Map);
      DatosBebida datosBebida = DatosBebida.fromJson(value);
      Bebida bebida = Bebida(clave: data.snapshot.key, datosBebida: datosBebida);
      int index = bebidaList.indexWhere((element) => element.clave == data.snapshot.key);
      if (index != -1) {
        bebidaList[index] = bebida;
        setState(() {});
      }
    });
  }
}
