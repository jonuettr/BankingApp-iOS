package com.jonuettr.banking_api.service;

import com.jonuettr.banking_api.entity.Device;
import com.jonuettr.banking_api.repository.DeviceRepository;

import org.springframework.stereotype.Service;

import java.util.Optional;


// Este servicio se encarga de consultar los
// dispositivos registrados de los clientes.
@Service
public class DeviceService {

    private final DeviceRepository deviceRepository;


    // Spring nos proporciona automáticamente
    // el DeviceRepository mediante inyección
    // de dependencias.
    public DeviceService(
            DeviceRepository deviceRepository) {

        this.deviceRepository = deviceRepository;
    }


    // Busca un dispositivo usando dos datos:
    //
    // 1. Su identificador único.
    // 2. El cliente al que debe pertenecer.
    //
    // Esto evita que alguien utilice el identificador
    // de un dispositivo perteneciente a otro cliente.
    public Optional<Device> getDevice(
            String identifier,
            Integer customerId) {

        return deviceRepository
                .findByIdentifierAndCustomerId(
                        identifier,
                        customerId
                );
    }
}
