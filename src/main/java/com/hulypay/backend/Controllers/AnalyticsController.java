package com.hulypay.backend.Controllers;

import com.hulypay.backend.ResponseDto.CategoryBreakdownResponse;
import com.hulypay.backend.ResponseDto.DailySpendingResponse;
import com.hulypay.backend.ResponseDto.MonthlySpendingResponse;
import com.hulypay.backend.ResponseDto.SpendingSummaryResponse;
import com.hulypay.backend.Models.User;
import com.hulypay.backend.Services.AnalyticsService;
import com.hulypay.backend.Services.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/analytics")
@RequiredArgsConstructor
public class AnalyticsController {

    private final AnalyticsService analyticsService;
    private final UserService userService;

    @GetMapping("/summary")
    public ResponseEntity<SpendingSummaryResponse> getSummary(@AuthenticationPrincipal Jwt jwt) {
        User user = userService.getUserFromJwt(jwt);
        return ResponseEntity.ok(analyticsService.getSpendingSummary(user));
    }

    @GetMapping("/category-breakdown")
    public ResponseEntity<List<CategoryBreakdownResponse>> getCategoryBreakdown(@AuthenticationPrincipal Jwt jwt) {
        User user = userService.getUserFromJwt(jwt);
        return ResponseEntity.ok(analyticsService.getCategoryBreakdown(user));
    }

    @GetMapping("/daily-spending")
    public ResponseEntity<List<DailySpendingResponse>> getDailySpending(@AuthenticationPrincipal Jwt jwt) {
        User user = userService.getUserFromJwt(jwt);
        return ResponseEntity.ok(analyticsService.getDailySpending(user));
    }

    @GetMapping("/monthly-spending")
    public ResponseEntity<List<MonthlySpendingResponse>> getMonthlySpending(@AuthenticationPrincipal Jwt jwt) {
        User user = userService.getUserFromJwt(jwt);
        return ResponseEntity.ok(analyticsService.getMonthlySpending(user));
    }
}


