
/*:
 # Implementacja wzorca Prototyp w Swift
 
 ## Zastosowanie
 
 Wzorzec projektowy prototyp (Prototype Pattern) tworzy nowy obiekt poprzez kopiowanie już istniejącego obiektu, nazywanego prototypem.
 Ten wzorze jest użyteczny, kiedy potrzebujemy utworzyć nowy obiekt, ale nie chcemy w tym celu używać konstruktora klasy.
 
 Ale dlaczego nie chcielibyśmy używać konstruktora? Jedna z odpowiedzi to kiedy jego użycie jest bardzo pracochłonne i nie chcemy za każdym razem robić tego samego. Może to być pobieranie dużych plików, łączenie z bazą danych i pobieranie danych itp.
 
 Głównym zagrożeniem w używaniu tego wzorca jest potrzeba uważnego zwrócenia uwagi na wybór stylu klonowania. Rozróżniamy dwa rodzaje, płytkie i głębokie kopiowanie (Shallow and Deep Copying).
 ![Shallow Vs Deep Copy](ShallowVsDeepCopy.png "http://stackoverflow.com/a/7811919")
 Przy kopiowaniu głębokim kopiujemy również obkety, które są wewnątrz naszego kopiowanego obiektu. Przy płytkim kilka obiektów ma referencje do jednego tego samego obiektu. Przy zmianie właściwości jednego z nich, inne również odwołują się do zmienionej wartości.
 
 */

/*:
 ## Przykład problemu
 
 Utworzę klasę obliczającą liczby pierwsze. W celu optymalizacji, w konstruktorze, będziemy obliczać 50 kolejnych liczb pierwszych, tak, żeby nie trzeba było za każdym razem ich obliczać. Liczby pierwsze będą przechowywane w tablicy cache obliczonych liczb pierwszych. Obiekty klasy primeNumber będą reprezentowały jedną n-tą liczbę pierwszą.
 */
import Foundation
import UIKit

class PrimeNumber: NSObject {
    private var calculatedPrimeNumbers: [Int] = []
    private var range = 50
    var nth = 0
    
    override init() {
        super.init()
    }
    
    convenience init(nth: Int) {
        self.init()
        // Ten konstruktor jest bardzo pracochłonny
        let startTime = NSDate()
        
        calculatedPrimeNumbers = [Int](count: range, repeatedValue: 0)
        for i in 0..<range {
            calculatedPrimeNumbers[i] = nthPrimeNumber(i)
        }
        
        let endTime = NSDate()
        print("Time execution \(endTime.timeIntervalSinceDate(startTime))")
        
        self.nth = nth
    }
    
    private init(nth: Int, calculatedPrimeNumbers: [Int]) {
        self.nth = nth
        self.calculatedPrimeNumbers = calculatedPrimeNumbers
    }
    
    private func nthPrimeNumber(n: Int) -> Int {
        var prime = 2
        var isPrime: Bool
        var counter = 0
        
        repeat {
            isPrime = true;
            for divisor in 2 ..< prime {
                if ((prime % divisor) == 0 ) {
                    isPrime = false
                }
            }
            if (isPrime) {
                counter += 1
            }
            prime += 1
        } while counter < n
        
        return prime-1
    }
    
    func number() -> Int {
        return calculatedPrimeNumbers[nth]
    }
}

/*:
 Nasz klasa liczb pierwszych działa, podczas tworzenia obiektu podaje, którą z kolei liczbę pierwszą reprezentuje obiekt.
 */

var primeNumber1 = PrimeNumber(nth: 1)
print("\(primeNumber1.number())") // liczba 2
var primeNumber2 = PrimeNumber(nth: 2)
print("\(primeNumber2.number())") // liczba 3

/*:
 Na razie jest źle, nasz konstruktor wywołany został już dwukrotnie, zajęło mu to po kilka sekund.
 Teraz spróbujmy skopiować obiekt.
 */

var primeNumber3 = primeNumber2
primeNumber3.nth = 3
print("\(primeNumber3.number())") // liczba 5

/*:
 Wygląda dobrze, konstruktor się nie wywołał kolejny raz, wynik poprawny. Dla pewności sprawdźmy wyniki jeszcze raz.
 */

print("\(primeNumber1.number())") // Wynik 2
print("\(primeNumber2.number())") // Wynik 5 ?!?!?! Powinno być 3
print("\(primeNumber3.number())") // Wynik 5 tu jest ok

/*:
 Niestety obiekty primeNumber2 i primeNumbe3 to te same obiekty, nie zostały sklonowane, było to kopiowanie płytkie.
 
 ## Kopiowanie głębokie (Deep Copying)
 
 W celu przeprowadzenia klonowania zaimplementujemy protokół NSCopying. Definiuje on metodę copyWithZone, w której będziemy określać, jak obiekt ma być klonowany. W celu implementacji protokołu musiałem wcześniej naszą klasę odziedziczyć z klasy NSObject, która dostarcza nam metodę copy()
 Rozszerzmy naszą klasę PrimeNumber o protokół NSCopying
 */

extension PrimeNumber: NSCopying {
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        return PrimeNumber(nth: self.nth, calculatedPrimeNumbers: self.calculatedPrimeNumbers)
    }
}

/*:
 
 W metodzie copyWithZone tworzymy nowy obiekt PrimeNumber. Wykorzystujemy do skopiowania istniejące już parametry, więc nie musimy wywoływać konstruktora z obliczaniem liczb pierwszych.
 
 */


let primeNumber4 = PrimeNumber(nth: 4)
let primeNumber5 = primeNumber4.copy() as! PrimeNumber
primeNumber5.nth = 5

print("\(primeNumber4.number())") // liczba 7
print("\(primeNumber5.number())") // liczba 11

/*: Wynik wygląda poprawnie, działanie jest ok. i konstruktor z obciążającymi obliczeniami nie jest wywoływany.
 
 
 # Podsumowanie
 
 Przedstawiłem tutaj jedno z możliwych rozwiązań problemu. Na pewno nie jest ono jedyna, ani nawet najlepsze, ale obrazuje ogólną ideę zastosowania wzorca prototypu.
 
 Temat kopiowania płytkiego i głębokiego został również bardzo pobieżnie przedstawiony. Nie pisałem nic o kopiowaniu typów referencyjnych, ale jeśli ktoś jest tym tematem zainteresowany, to proszę zostawić informację w komentarzu, rozszerzę temat kopiowania w innym poście.
 */
