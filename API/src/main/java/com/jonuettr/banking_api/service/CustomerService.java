package com.jonuettr.banking_api.service;

import com.jonuettr.banking_api.entity.Customer;
import com.jonuettr.banking_api.repository.CustomerRepository;

import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class CustomerService {

    private final CustomerRepository customerRepository;

    public CustomerService(CustomerRepository customerRepository) {
        this.customerRepository = customerRepository;
    }

    public Optional<Customer> getCustomerById(Integer id) {
        return customerRepository.findById(id);
    }
}