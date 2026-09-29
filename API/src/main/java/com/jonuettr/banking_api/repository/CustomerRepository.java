package com.jonuettr.banking_api.repository;

import com.jonuettr.banking_api.entity.Customer;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface CustomerRepository extends JpaRepository<Customer, Integer> {

// El correo funcionará como identificador de inicio de sesión.
Optional<Customer> findByEmailAndActiveTrue(
        String email
);
}
