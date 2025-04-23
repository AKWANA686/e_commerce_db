-- CREATE DATABASE e_commerceDB;
USE e_commercedb;
 -- product_image table which stores product image references
CREATE TABLE product_image(
    image_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL, -- This is a foreIgn key for products table that should be created.
    image_url VARCHAR(300) NOT NULL,
    color_id INT, -- Links to color table if image is color-specific
    is_primary BOOLEAN DEFAULT FALSE,
    sort_order INT DEFAULT 0,
    alt_text VARCHAR(150),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (color_id) REFERENCES color(color_id) ON DELETE SET NULL,
    CONSTRAINT uc_product_image UNIQUE (product_id, image_url)
);

-- Color Table to store the color options
CREATE TABLE color (
    color_id INT AUTO_INCREMENT PRIMARY KEY,
    color_name VARCHAR(50) NOT NULL,
    hex_code VARCHAR(7) NOT NULL, -- This stores color in HEX format
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uc_color_name UNIQUE (color_name),
    CONSTRAINT uc_hex_code UNIQUE (hex_code)
);

-- Stores hierarchical product categories (e.g., Electronics → Phones → Smartphones)
CREATE TABLE product_category (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL,
    parent_category_id INT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_category_id) REFERENCES product_category(category_id)
);

-- Core product information table
-- Contains common attributes for all products regardless of variations
CREATE TABLE product (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(255) NOT NULL,
    description TEXT,
    brand_id INT NOT NULL,
    base_price DECIMAL(10,2) NOT NULL,
    category_id INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (brand_id) REFERENCES brand(brand_id),
    FOREIGN KEY (category_id) REFERENCES product_category(category_id)
);

-- Represents actual purchasable items (SKUs)
-- Each record is a unique combination of variations with its own inventory
CREATE TABLE product_item (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    sku VARCHAR(50) NOT NULL UNIQUE,
    price DECIMAL(10,2) NOT NULL,
    quantity_in_stock INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);

-- Contains brand information for products
-- Brand is separated from products for normalization and reuse
CREATE TABLE brand (
    brand_id INT PRIMARY KEY AUTO_INCREMENT,
    brand_name VARCHAR(100) NOT NULL,
    description TEXT,
    logo_url VARCHAR(255),
    website_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Defines types of variations a product can have
-- Each product can have multiple variation types (size, color, etc.)
CREATE TABLE product_variation (
    variation_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    variation_name VARCHAR(100) NOT NULL,
    variation_type ENUM('size', 'color', 'material', 'other') NOT NULL,
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);

-- Defines types of size systems (e.g., Clothing, Shoes, Electronics)
-- Allows different sizing systems per product category
CREATE TABLE size_category (
    size_category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL,
    description VARCHAR(255)
);

-- Specific size values within a size category
-- Contains actual sizes like S/M/L or numerical sizes
CREATE TABLE size_option (
    size_id INT PRIMARY KEY AUTO_INCREMENT,
    size_category_id INT NOT NULL,
    size_value VARCHAR(20) NOT NULL,
    size_order INT,
    FOREIGN KEY (size_category_id) REFERENCES size_category(size_category_id);
);

-- Defines custom attributes that products can have
-- Flexible system for product specifications
CREATE TABLE product_attribute(
    attribute_id INT PRIMARY KEY AUTO_INCREMENT,
    attribute_name VARCHAR(100) NOT NULL,
    attribute_category_id INT NOT NULL,
    attribute_type_id INT NOT NULL,
    is_required BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (attribute_category_id) REFERENCES attribute_category(attribute_category_id),
    FOREIGN KEY (attribute_type_id) REFERENCES attribute_type(attribute_type_id)
);

-- Groups related attributes together
-- Helps organize attributes in UI (e.g., "Technical Specs", "Fabric Details")
CREATE TABLE attribute_category (
    attribute_category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL,
    description TEXT
);

-- Defines data types for product attributes
-- Ensures type safety for attribute values
CREATE TABLE attribute_type (
    atribute_type_id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(50) NOT NULL,
    data_type ENUM('text', 'number', 'boolean', 'date') NOT NULL
);