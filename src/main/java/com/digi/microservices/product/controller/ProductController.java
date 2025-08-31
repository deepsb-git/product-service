package com.digi.microservices.product.controller;

import com.digi.microservices.product.dto.ProductRequest;
import com.digi.microservices.product.dto.ProductResponse;
import com.digi.microservices.product.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ProductResponse createProduct(@RequestBody ProductRequest productRequest){
        return productService.createProduct(productRequest);
    }

    @GetMapping
    @ResponseStatus(HttpStatus.OK)
    List<ProductResponse> getAllProducts(){
        return productService.getAllProducts();
    }

}
