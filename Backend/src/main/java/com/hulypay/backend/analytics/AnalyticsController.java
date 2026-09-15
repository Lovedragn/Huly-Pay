package com.hulypay.backend.analytics;

import com.hulypay.backend.analytics.dto.CategoryBreakdownResponse;
import com.hulypay.backend.analytics.dto.DailySpendingResponse;
import com.hulypay.backend.analytics.dto.MonthlySpendingResponse;
import com.hulypay.backend.analytics.dto.SpendingSummaryResponse;
import com.hulypay.backend.users.User;
import com.hulypay.backend.users.UserService;
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
