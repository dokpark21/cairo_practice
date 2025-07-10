//fib.cairo

// loop version, recursion version is not efficient in Cairo
fn fibonacci(n: u32) -> felt252 {
    if n == 0 {
        return 0;
    } else if n == 1 {
        return 1;
    } 

    let mut a = 0;
    let mut b = 1;
    let mut next = 0;
    let mut i = 2;

    while i <= n {
        next = a + b;
        a = b;
        b = next;
        i += 1;
    }

    return b;
}

// main fn
#[executable]
fn main() {
    let result = fibonacci(10);
    println!("Fibonacci(10) = {}", result);
}