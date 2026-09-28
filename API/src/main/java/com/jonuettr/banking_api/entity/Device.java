package com.jonuettr.banking_api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.LocalDateTime;


// Esta clase representa un dispositivo registrado
// para un cliente.
//
// Ejemplos:
// - iPhone principal
// - iPad nuevo
//
// La información proviene de la tabla DEVICE.
@Entity
@Table(name = "DEVICE")
public class Device {

    // ID del dispositivo.
    //
    // Por ahora no usamos @GeneratedValue porque los
    // dispositivos actuales fueron creados en nuestros
    // datos iniciales con IDs definidos.
    @Id
    @Column(name = "id_device")
    private Integer id;


    // Cliente propietario del dispositivo.
    @Column(name = "id_customer", nullable = false)
    private Integer customerId;


    // Nombre que verá el usuario.
    //
    // Ejemplo:
    // "iPhone principal"
    @Column(name = "device_name", nullable = false)
    private String name;


    // Tipo de dispositivo.
    //
    // Ejemplo:
    // "iPhone"
    // "iPad"
    @Column(name = "device_type", nullable = false)
    private String type;


    // Identificador único del dispositivo.
    //
    // En MySQL esta columna tiene una restricción UNIQUE.
    @Column(name = "device_identifier", nullable = false, unique = true)
    private String identifier;


    // Indica si el dispositivo ya es considerado confiable.
    //
    // Este campo será muy importante para el motor de riesgo.
    @Column(name = "is_trusted", nullable = false)
    private Boolean trusted;


    // Momento en el que se registró el dispositivo.
    @Column(name = "registered_at", nullable = false)
    private LocalDateTime registeredAt;


    // Último acceso conocido.
    //
    // Puede ser null.
    @Column(name = "last_access_at")
    private LocalDateTime lastAccessAt;


    // JPA necesita un constructor vacío para poder
    // reconstruir objetos obtenidos desde MySQL.
    public Device() {
    }


    public Integer getId() {
        return id;
    }

    public Integer getCustomerId() {
        return customerId;
    }

    public String getName() {
        return name;
    }

    public String getType() {
        return type;
    }

    public String getIdentifier() {
        return identifier;
    }

    public Boolean getTrusted() {
        return trusted;
    }

    public LocalDateTime getRegisteredAt() {
        return registeredAt;
    }

    public LocalDateTime getLastAccessAt() {
        return lastAccessAt;
    }
}


