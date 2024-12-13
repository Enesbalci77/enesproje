import Time "mo:base/Time";
import Random "mo:base/Random";
import Int "mo:base/Int";
import Debug "mo:base/Debug";
import Timer "mo:base/Timer";
import Nat8 "mo:base/Nat8";

actor AlarmGamePlayer {
  // Game state variables
  var alarmTime : Time.Time = 0;
  var isAlarmActive : Bool = false;
  var currentMathChallenge : (Nat8, Nat8, Nat8) = (0, 0, 0); // (num1, num2, correctAnswer)
  var gameTimer : ?Timer.TimerId = null;

  // Alarm and game settings
  let ALARM_DURATION : Int = 300; // 5 minutes in seconds
  let MAX_NUMBER : Int = 20; // Maximum number for math challenge
  let MAX_GAME_ATTEMPTS : Nat = 3; // Maximum attempts before alarm stops
  var currentAttempts : Nat = 0;

  // Start the alarm and game
  public func setAlarmAndStartGame(time : Time.Time) : async Bool {
    alarmTime := time;
    isAlarmActive := true;
    currentAttempts := 0;

    // Generate initial challenge
    await generateMathChallenge();

    // Zamanlayıcıyı başlat
currentAttempts += 1;
// Check if max attempts reached
if (currentAttempts >= MAX_GAME_ATTEMPTS) {
    await stopAlarm();
    return false;
};

Debug.print("Alarm set and game started!");
return true;

  
  };
    


  // Generate a random math challenge
  private func generateMathChallenge() : async () {
    let seed = await Random.blob();
    let seed2 = await Random.blob();
    let generator = Random.Finite(seed);

    let randomNat = Random.byteFrom(seed);
    let randomNat2 = Random.byteFrom(seed2);

    

    // Randomly choose between addition, subtraction, and multiplication
    let operationType =  randomNat % 3;

    let challenge = switch (operationType) {
      case (0) {
        // Addition
        (randomNat, randomNat2, randomNat + randomNat2)
      };
      case (1) {
        // Subtraction
        (randomNat + randomNat2, randomNat2, randomNat)
      };
      case (_) {
        // Multiplication
        (randomNat, randomNat2, randomNat * randomNat2)
      }
    };

    currentMathChallenge := challenge;
    Debug.print("New math challenge generated!")
  };

  // Verify the user's solution
  public func solveMiniGame(userAnswer : Int) : async Bool {
    // Check if alarm is active
    if (not isAlarmActive) {
      return false
    };

    // Increment attempts
    currentAttempts += 1;
    // Check if max attempts reached
    if (currentAttempts >= MAX_GAME_ATTEMPTS) {
      await stopAlarm();
      return false
    };
  

  // Check if the answer is correct
  let (num1, num2, correctAnswer) = currentMathChallenge;

  if (userAnswer == correctAnswer) {
    // Correct solution - stop the alarm
    await stopAlarm();
    return true
  } else {
    // Incorrect solution - generate new challenge
    await generateMathChallenge();
    return false
  }
};

// Stop the alarm
public func stopAlarm() : async () {
  // Cancel the timer if it exists
  switch (gameTimer) {
    case (?timerId) {Timer.cancelTimer(timerId)};
    case (null) {}
  };

  isAlarmActive := false;
  gameTimer := null;
  Debug.print("Alarm stopped!")
};

// Get current math challenge for the user
public query func getCurrentChallenge() : async Text {
  let (num1, num2, _) = currentMathChallenge;
  return "Solve: " # Nat8.toText(num1) # " * " # Nat8.toText(num2)
};

// Check if alarm is currently active
public query func checkAlarmStatus() : async Bool {
  return isAlarmActive
}}
