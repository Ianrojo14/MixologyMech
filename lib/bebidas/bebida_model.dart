class Bebida {
  String? clave;
  DatosBebida datosBebida;

  Bebida({this.clave, required this.datosBebida});

  factory Bebida.fromJson(Map<String, dynamic> json) {
    return Bebida(
      clave: json['clave'],
      datosBebida: DatosBebida.fromJson(json['datosBebida']),
    );
  }
}

class DatosBebida {
  String nombre;
  String cantidad;
  String precio;

  DatosBebida({required this.nombre, required this.cantidad, required this.precio});

  factory DatosBebida.fromJson(Map<String, dynamic> json) {
    return DatosBebida(
      nombre: json['nombre'],
      cantidad: json['cantidad'],
      precio: json['precio'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'cantidad': cantidad,
    };
  }
}