package com.flo.auth;

import com.flo.auth.dto.AuthResponse;
import com.flo.auth.dto.LoginRequest;
import com.flo.auth.dto.RegisterRequest;
import com.flo.common.response.ApiResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<AuthResponse>> register(
            @Valid @RequestBody RegisterRequest req) {
        AuthResponse data = authService.register(req);
        return ResponseEntity.status(201)
                .body(ApiResponse.success("User registered successfully", data));
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(
            @Valid @RequestBody LoginRequest req) {
        AuthResponse data = authService.login(req);
        return ResponseEntity.ok(ApiResponse.success("Login successful", data));
    }
}
