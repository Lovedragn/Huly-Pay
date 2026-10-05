package com.hulypay.backend.Controllers;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.util.UriComponentsBuilder;

import java.io.ByteArrayOutputStream;
import java.math.BigDecimal;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/qr")
public class QrCodeController {

    @PostMapping(value = "/generate", produces = MediaType.IMAGE_PNG_VALUE)
    public ResponseEntity<byte[]> generateQrCodePost(@RequestBody Map<String, Object> request) {
        String uri = (String) request.get("uri");
        Number amountNum = (Number) request.get("amount");
        BigDecimal amount = amountNum != null ? BigDecimal.valueOf(amountNum.doubleValue()) : null;
        Integer size = request.get("size") instanceof Number num ? num.intValue() : 512;

        return generateQrResponse(uri, amount, size);
    }

    @GetMapping(value = "/generate", produces = MediaType.IMAGE_PNG_VALUE)
    public ResponseEntity<byte[]> generateQrCodeGet(
            @RequestParam("uri") String uri,
            @RequestParam(value = "amount", required = false) BigDecimal amount,
            @RequestParam(value = "size", required = false, defaultValue = "512") int size
    ) {
        return generateQrResponse(uri, amount, size);
    }

    private ResponseEntity<byte[]> generateQrResponse(String uri, BigDecimal amount, int size) {
        if (uri == null || uri.isBlank()) {
            return ResponseEntity.badRequest().build();
        }

        try {
            String decodedUri = uri;
            if (decodedUri.contains("%20") || decodedUri.contains("%3F") || decodedUri.contains("%3D") || decodedUri.contains("%26")) {
                decodedUri = URLDecoder.decode(decodedUri, StandardCharsets.UTF_8);
            }

            // If amount is provided, update or append am parameter in the URI
            String targetUri = decodedUri;
            if (amount != null && amount.compareTo(BigDecimal.ZERO) > 0) {
                targetUri = injectAmountIntoUpiUri(decodedUri, amount);
            }

            QRCodeWriter qrCodeWriter = new QRCodeWriter();
            Map<EncodeHintType, Object> hints = new HashMap<>();
            hints.put(EncodeHintType.CHARACTER_SET, "UTF-8");
            hints.put(EncodeHintType.MARGIN, 1);
            hints.put(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.M);

            BitMatrix bitMatrix = qrCodeWriter.encode(targetUri, BarcodeFormat.QR_CODE, size, size, hints);

            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            MatrixToImageWriter.writeToStream(bitMatrix, "PNG", outputStream);
            byte[] pngBytes = outputStream.toByteArray();

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.IMAGE_PNG);
            headers.setContentLength(pngBytes.length);
            headers.setCacheControl("no-cache, no-store, must-revalidate");

            return new ResponseEntity<>(pngBytes, headers, HttpStatus.OK);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    private String injectAmountIntoUpiUri(String rawUri, BigDecimal amount) {
        String formattedAmount = String.format("%.2f", amount);
        if (!rawUri.contains("?")) {
            return rawUri + "?am=" + formattedAmount;
        }

        String[] parts = rawUri.split("\\?", 2);
        String base = parts[0];
        String query = parts[1];

        // Replace existing am param or append
        if (query.matches("(?i)(^|.*&)am=[^&]*.*")) {
            query = query.replaceAll("(?i)(^|&)am=[^&]*", "$1am=" + formattedAmount);
        } else {
            query = query + "&am=" + formattedAmount;
        }

        return base + "?" + query;
    }
}
