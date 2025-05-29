package demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class Runner {
    public static void main(String[] args){

        SpringApplication.run(Runner.class, args);
        /*Uni.createFrom()
                .item(() -> 1)
                .onItem().transform((i) -> i * i)
                .subscribe().with(System.out::println);

      System.out.println("hello world");*/
    }
}