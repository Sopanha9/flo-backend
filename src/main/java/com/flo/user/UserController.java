package com.flo.user;

import com.flo.common.response.ApiResponse;
import com.flo.user.entity.User;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<User>> getMe() {
        User user = userService.getCurrentUser();
        return ResponseEntity.ok(ApiResponse.success(user));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<User>> getById(@PathVariable UUID id) {
        User user = userService.getById(id);
        return ResponseEntity.ok(ApiResponse.success(user));
    }
}
