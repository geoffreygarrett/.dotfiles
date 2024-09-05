#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! yaml-rust = "0.4"
//! ```

use yaml_rust::{YamlLoader, YamlEmitter, Yaml};
use std::collections::HashMap;

#[derive(Debug)]
struct Config {
    keys: Vec<String>,
    creation_rules: Vec<CreationRule>,
}

#[derive(Debug)]
struct CreationRule {
    path_regex: String,
    key_groups: Vec<KeyGroup>,
}

#[derive(Debug)]
struct KeyGroup {
    age: Vec<String>,
}

fn main() {
    let yaml_data = r#"
        keys:
          - &build01 age17jtyn2y4fpey6q7ers9gtnh4580xj89zdjuew9nqhxywmsaw94fs5udupc
          - &build02 age1kh6yvgxz9ys74as7aufdy8je7gmqjtguhnjuxvj79qdjswk2r3xqxf2n6d
          - &build03 age1qg7tfjwzp6dxwkw9vej6knkhdvqre3fu7ryzsdk5ggvtdx854ycqevlwnq
          - &build04 age1r464z5e2shvnh9ekzapgghevr9wy7spd4d7pt5a89ucdk6kr6yhqzv5gkj
          - &web02 age158v8dpppnw3yt2kqgqekwamaxpst5alfrnvvt7z36wfdk4veydrsqxc2tl
          - &mic92 age17n64ahe3wesh8l8lj0zylf4nljdmqn28hvqns2g7hgm9mdkhlsvsjuvkxz
          - &ryantm age1d87z3zqlv6ullnzyng8l722xzxwqr677csacf3zf3l28dau7avfs6pc7ay
          - &zimbatm age1jrh8yyq3swjru09s75s4mspu0mphh7h6z54z946raa9wx3pcdegq0x8t4h
          - &zowoq age1m7xhem3qll35d539f364pm6txexvnp6k0tk34d8jxu4ry3pptv7smm0k5n
          - &adisbladis age1dzvjjum2p240qtdt2qcxpm7pl2s5w36mh4fs3q9dhhq0uezvdqaq9vrgfy
        # scan new hosts with `scan-age-keys` task
        creation_rules:
          - path_regex: ^secrets.yaml$
            key_groups:
              - age:
                  - *mic92
                  - *ryantm
                  - *zimbatm
                  - *zowoq
                  - *adisbladis
          - path_regex: terraform/secrets.yaml$
            key_groups:
              - age:
                  - *mic92
                  - *ryantm
                  - *zimbatm
                  - *zowoq
                  - *adisbladis
          - path_regex: hosts/build02/[^/]+\.yaml$
            key_groups:
              - age:
                  - *build02
                  - *mic92
                  - *ryantm
                  - *zimbatm
                  - *zowoq
                  - *adisbladis
          - path_regex: hosts/build03/[^/]+\.yaml$
            key_groups:
              - age:
                  - *build03
                  - *mic92
                  - *ryantm
                  - *zimbatm
                  - *zowoq
                  - *adisbladis
          - path_regex: hosts/web02/[^/]+\.yaml$
            key_groups:
              - age:
                  - *web02
                  - *mic92
                  - *ryantm
                  - *zimbatm
                  - *zowoq
                  - *adisbladis
    "#;

    // Load YAML data
    let docs = YamlLoader::load_from_str(yaml_data).unwrap();
    let mut doc = docs[0].clone();

    // Add a new key and anchor it
    let new_key = Yaml::String("age1newkey1234567890abcdefg".to_string());
    let new_key_anchor = Yaml::Alias("new_key".to_string());

    // Insert the new key with an anchor
    doc["keys"].as_vec_mut().unwrap().push(new_key);
    doc["keys"].as_vec_mut().unwrap().push(new_key_anchor);

    // Optionally, you can add the new key to the creation rules
    if let Some(creation_rules) = doc["creation_rules"].as_vec_mut() {
        for rule in creation_rules {
            if let Some(key_groups) = rule["key_groups"].as_vec_mut() {
                for key_group in key_groups {
                    key_group["age"].as_vec_mut().unwrap().push(new_key_anchor.clone());
                }
            }
        }
    }

    // Create Config struct
    let config = Config {
        keys: doc["keys"].as_vec().unwrap().iter()
            .map(|k| k.as_str().unwrap().to_string())
            .collect(),
        creation_rules: doc["creation_rules"].as_vec().unwrap().iter()
            .map(|rule| {
                CreationRule {
                    path_regex: rule["path_regex"].as_str().unwrap().to_string(),
                    key_groups: rule["key_groups"]
                        .as_vec().unwrap()
                        .iter()
                        .map(|kg| KeyGroup {
                            age: kg["age"].as_vec().unwrap()
                                .iter()
                                .map(|a| a.as_str().unwrap().to_string())
                                .collect(),
                        })
                        .collect(),
                }
            })
            .collect(),
    };

    // Print the modified config
    println!("{:#?}", config);

    // Emit the modified YAML data
    let mut emitter = YamlEmitter::new(std::io::stdout());
    emitter.dump(&doc).unwrap();
}