package com.satya.assignment.web;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.util.UriComponentsBuilder;

import java.io.IOException;
import java.util.UUID;

@RestController
@RequestMapping("/books")
public class BookController {

    private final RestTemplate restTemplate;

    @Value("${app.mylib-be.url:http://localhost:8080/api}")
    private String mylibBeUrl;

    private static final String MOCK_TOKEN = "BFF-GATEWAY-SECRET-TOKEN";

    public BookController(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    @GetMapping
    public ResponseEntity<Object> listBooks(
            @RequestParam(required = false) String q,
            @RequestParam(required = false) Boolean available,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {

        String url = mylibBeUrl + "/books?page=" + page + "&size=" + size;
        if (q != null && !q.isEmpty()) {
            try {
                url += "&q=" + java.net.URLEncoder.encode(q, "UTF-8");
            } catch (java.io.UnsupportedEncodingException e) {
                // fallback
            }
        }
        if (available != null) {
            url += "&available=" + available;
        }

        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(MOCK_TOKEN);
        HttpEntity<Void> entity = new HttpEntity<>(headers);

        try {
            return restTemplate.exchange(url, HttpMethod.GET, entity, Object.class);
        } catch (HttpStatusCodeException e) {
            return ResponseEntity.status(e.getStatusCode())
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(e.getResponseBodyAsString());
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<Object> getBook(@PathVariable UUID id) {
        String url = mylibBeUrl + "/books/" + id;

        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(MOCK_TOKEN);
        HttpEntity<Void> entity = new HttpEntity<>(headers);

        try {
            return restTemplate.exchange(url, HttpMethod.GET, entity, Object.class);
        } catch (HttpStatusCodeException e) {
            return ResponseEntity.status(e.getStatusCode())
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(e.getResponseBodyAsString());
        }
    }

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<Object> createBook(
            @RequestParam("title") String title,
            @RequestParam("author") String author,
            @RequestParam("isbn") String isbn,
            @RequestParam(value = "synopsis", required = false) String synopsis,
            @RequestParam(value = "thumbnail", required = false) MultipartFile thumbnail) throws IOException {

        String url = mylibBeUrl + "/books";

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.MULTIPART_FORM_DATA);
        headers.setBearerAuth(MOCK_TOKEN);

        MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
        body.add("title", title);
        body.add("author", author);
        body.add("isbn", isbn);
        if (synopsis != null) {
            body.add("synopsis", synopsis);
        }
        if (thumbnail != null && !thumbnail.isEmpty()) {
            body.add("thumbnail", new MultipartInputStreamFileResource(thumbnail));
        }

        HttpEntity<MultiValueMap<String, Object>> entity = new HttpEntity<>(body, headers);

        try {
            return restTemplate.exchange(url, HttpMethod.POST, entity, Object.class);
        } catch (HttpStatusCodeException e) {
            return ResponseEntity.status(e.getStatusCode())
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(e.getResponseBodyAsString());
        }
    }

    @PutMapping(path = "/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<Object> updateBook(
            @PathVariable UUID id,
            @RequestParam("title") String title,
            @RequestParam("author") String author,
            @RequestParam("isbn") String isbn,
            @RequestParam(value = "synopsis", required = false) String synopsis,
            @RequestParam(value = "thumbnail", required = false) MultipartFile thumbnail) throws IOException {

        String url = mylibBeUrl + "/books/" + id;

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.MULTIPART_FORM_DATA);
        headers.setBearerAuth(MOCK_TOKEN);

        MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
        body.add("title", title);
        body.add("author", author);
        body.add("isbn", isbn);
        if (synopsis != null) {
            body.add("synopsis", synopsis);
        }
        if (thumbnail != null && !thumbnail.isEmpty()) {
            body.add("thumbnail", new MultipartInputStreamFileResource(thumbnail));
        }

        HttpEntity<MultiValueMap<String, Object>> entity = new HttpEntity<>(body, headers);

        try {
            return restTemplate.exchange(url, HttpMethod.PUT, entity, Object.class);
        } catch (HttpStatusCodeException e) {
            return ResponseEntity.status(e.getStatusCode())
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(e.getResponseBodyAsString());
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Object> deleteBook(@PathVariable UUID id) {
        String url = mylibBeUrl + "/books/" + id;

        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(MOCK_TOKEN);
        HttpEntity<Void> entity = new HttpEntity<>(headers);

        try {
            return restTemplate.exchange(url, HttpMethod.DELETE, entity, Object.class);
        } catch (HttpStatusCodeException e) {
            return ResponseEntity.status(e.getStatusCode())
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(e.getResponseBodyAsString());
        }
    }

    // Helper class to pass MultipartFile as resource in RestTemplate
    private static class MultipartInputStreamFileResource extends org.springframework.core.io.InputStreamResource {
        private final String filename;

        public MultipartInputStreamFileResource(MultipartFile file) throws IOException {
            super(file.getInputStream());
            this.filename = file.getOriginalFilename();
        }

        @Override
        public String getFilename() {
            return this.filename;
        }

        @Override
        public long contentLength() throws IOException {
            return -1; // let Spring handle content length
        }
    }
}
