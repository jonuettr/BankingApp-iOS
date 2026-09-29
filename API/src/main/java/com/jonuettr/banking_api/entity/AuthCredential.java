package com.jonuettr.banking_api.entity;

import jakarta.persistence.*;

import java.time.LocalDateTime;


// Representa las credenciales de autenticación almacenadas
// en AUTH_CREDENTIAL.
//
// Aquí nunca guardamos la contraseña original.
// Solamente almacenamos su hash BCrypt.
@Entity
@Table(name = "AUTH_CREDENTIAL")
public class AuthCredential {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_credential")
    private Integer id;

    @Column(
        name = "id_customer",
        nullable = false,
        unique = true
    )
    private Integer customerId;

    @Column(
        name = "password_hash",
        nullable = false,
        length = 255
    )
    private String passwordHash;

    @Column(name = "is_active", nullable = false)
    private Boolean active;

    @Column(
        name = "created_at",
        insertable = false,
        updatable = false
    )
    private LocalDateTime createdAt;

    @Column(
        name = "updated_at",
        insertable = false,
        updatable = false
    )
    private LocalDateTime updatedAt;


    // JPA necesita un constructor vacío.
    protected AuthCredential() {
    }


    public AuthCredential(
            Integer customerId,
            String passwordHash) {

        this.customerId = customerId;
        this.passwordHash = passwordHash;
        this.active = true;
    }


    public Integer getId() {
        return id;
    }

    public Integer getCustomerId() {
        return customerId;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public Boolean getActive() {
        return active;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }
}

