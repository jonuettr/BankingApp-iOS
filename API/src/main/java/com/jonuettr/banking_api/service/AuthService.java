package com.jonuettr.banking_api.service;

import com.jonuettr.banking_api.dto.LoginRequest;
import com.jonuettr.banking_api.dto.LoginResponse;
import com.jonuettr.banking_api.entity.AuthCredential;
import com.jonuettr.banking_api.entity.Customer;
import com.jonuettr.banking_api.repository.AuthCredentialRepository;
import com.jonuettr.banking_api.repository.CustomerRepository;
import com.jonuettr.banking_api.exception.InvalidCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;


// Contiene la lógica de autenticación.
//
// El controlador HTTP no conoce BCrypt ni consulta
// directamente la base de datos. Esa responsabilidad
// pertenece a esta capa de servicio.
@Service
public class AuthService {

    private final CustomerRepository customerRepository;

    private final AuthCredentialRepository
            authCredentialRepository;

    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

	public AuthService(
        	CustomerRepository customerRepository,
        	AuthCredentialRepository authCredentialRepository,
        	PasswordEncoder passwordEncoder,
        	JwtService jwtService) {

    	this.customerRepository =
            customerRepository;

    	this.authCredentialRepository =
            authCredentialRepository;

    	this.passwordEncoder =
            passwordEncoder;

    	this.jwtService =
            jwtService;
}

public LoginResponse login(
        LoginRequest request) {

    // Normalizamos el correo para evitar diferencias
    // por espacios o mayúsculas.
    String normalizedEmail =
            request.email()
                    .trim()
                    .toLowerCase();


    // Primero buscamos un cliente activo.
    //
    // Si el correo no existe, devolvemos exactamente
    // el mismo tipo de error que para una contraseña
    // incorrecta. Así no revelamos qué usuarios existen.
    Customer customer =
            customerRepository
                    .findByEmailAndActiveTrue(
                            normalizedEmail
                    )
                    .orElseThrow(
                            InvalidCredentialsException::new
                    );


    // Después buscamos las credenciales activas
    // correspondientes a ese cliente.
    AuthCredential credential =
            authCredentialRepository
                    .findByCustomerIdAndActiveTrue(
                            customer.getId()
                    )
                    .orElseThrow(
                            InvalidCredentialsException::new
                    );


    // BCrypt compara la contraseña recibida con
    // el hash almacenado en AUTH_CREDENTIAL.
    //
    // La contraseña original nunca se recupera
    // ni se desencripta.
    boolean passwordMatches =
            passwordEncoder.matches(
                    request.password(),
                    credential.getPasswordHash()
            );


    if (!passwordMatches) {

        throw new InvalidCredentialsException();
    }


    // Si llegamos aquí, tanto el correo como
    // la contraseña son válidos.
String accessToken =
        jwtService.generateToken(
                customer.getId(),
                customer.getEmail()
        );
	return new LoginResponse(
        	customer.getId(),
        	customer.getFirstName(),
        	customer.getLastName(),
        	customer.getEmail(),
        	accessToken,

        3600
);
}
}
