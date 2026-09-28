package com.jonuettr.banking_api.repository;

import com.jonuettr.banking_api.entity.Device;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;


// Repository para acceder a la tabla DEVICE.
public interface DeviceRepository
        extends JpaRepository<Device, Integer> {

    // Busca un dispositivo por su identificador único
    // y verifica además que pertenezca al cliente indicado.
    //
    // Spring Data JPA construye automáticamente
    // la consulta a partir del nombre del método.
    Optional<Device> findByIdentifierAndCustomerId(
            String identifier,
            Integer customerId
    );
}
