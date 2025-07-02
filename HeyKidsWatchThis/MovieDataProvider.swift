// MovieDataProvider.swift
// FINAL VERSION
// Contains the full, restored list of 153 movies.

import Foundation

class MovieDataProvider: MovieDataProviderProtocol {
    
    private let userDefaults: UserDefaults
    private let watchlistKey = "stored_watchlist"
    private let watchedMoviesKey = "stored_watched_movies"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        print("🏗️ MovieDataProvider initialized with key: \(watchlistKey)")
    }
    
    func loadMovies() -> [MovieData] {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let moviesURL = documentsURL.appendingPathComponent("movies.json")
        
        // If the movie file doesn't exist, create it from the master list.
        if !FileManager.default.fileExists(atPath: moviesURL.path) {
             let builtInMovies = createSampleMovies()
             saveMoviesToFile(builtInMovies)
             return builtInMovies
        }

        // If the file does exist, load it.
        do {
            let data = try Data(contentsOf: moviesURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let movies = try decoder.decode([MovieData].self, from: data)
            print("📂 Loaded \(movies.count) movies from file storage")
            return movies
        } catch {
            print("⚠️ Failed to load movies from file: \(error). Recreating from master list.")
            // If loading fails, it might be corrupted, so recreate it.
            let builtInMovies = createSampleMovies()
            saveMoviesToFile(builtInMovies)
            return builtInMovies
        }
    }
    
    private func saveMoviesToFile(_ movies: [MovieData]) {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let moviesURL = documentsURL.appendingPathComponent("movies.json")
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(movies)
            try data.write(to: moviesURL)
            print("📂 Saved \(movies.count) movies to file storage")
        } catch {
            print("⚠️ Failed to save movies to file: \(error)")
        }
    }
    
    func loadWatchlist() -> [UUID] {
        guard let data = userDefaults.data(forKey: watchlistKey) else {
            return []
        }
        do {
            return try JSONDecoder().decode([UUID].self, from: data)
        } catch {
            return []
        }
    }
    
    func saveWatchlist(_ watchlist: [UUID]) {
        do {
            let data = try JSONEncoder().encode(watchlist)
            userDefaults.set(data, forKey: watchlistKey)
        } catch {
            print("⚠️ Failed to save watchlist: \(error)")
        }
    }
    
    func loadWatchedMovies() -> [UUID: Date] {
        guard let data = userDefaults.data(forKey: watchedMoviesKey) else { return [:] }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([UUID: Date].self, from: data)
        } catch {
            return [:]
        }
    }
    
    func saveWatchedMovies(_ watchedMovies: [UUID: Date]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(watchedMovies)
            userDefaults.set(data, forKey: watchedMoviesKey)
        } catch {
            print("⚠️ Failed to save watched movies: \(error)")
        }
    }
    
    // The master list of movies built into the app.
    private func createSampleMovies() -> [MovieData] {
        return [
            // Preschoolers (2-4)
            MovieData(title: "Fantastic Mr. Fox", year: 2009, ageGroup: .preschoolers, genre: "Animation", emoji: "🦊", streamingServices: ["Max", "Hulu"], rating: 4.0, notes: "A clever fox's thievery results in his community being hunted by farmers."),
            MovieData(title: "Rainbow Dance", year: 1936, ageGroup: .preschoolers, genre: "Short", emoji: "🌈", streamingServices: ["YouTube"], rating: 3.5, notes: "A pioneering abstract animated film by Len Lye."),
            MovieData(title: "Mermaid", year: 1997, ageGroup: .preschoolers, genre: "Short", emoji: "🧜‍♀️", streamingServices: ["YouTube"], rating: 4.1, notes: "A paint-on-glass animated short about a monk's memories."),
            MovieData(title: "Hedgehog in the Fog", year: 1975, ageGroup: .preschoolers, genre: "Short", emoji: "🦔", streamingServices: ["The Criterion Channel"], rating: 4.2, notes: "A little hedgehog gets lost in the fog on his way to visit his friend, the bear."),
            MovieData(title: "The Story of Hansel and Gretel", year: 1951, ageGroup: .preschoolers, genre: "Short", emoji: "🍬", streamingServices: ["YouTube"], rating: 3.8, notes: "A stop-motion telling of the classic fairytale."),
            MovieData(title: "School for Postmen", year: 1947, ageGroup: .preschoolers, genre: "Short", emoji: "📬", streamingServices: ["The Criterion Channel"], rating: 3.9, notes: "A French postman tries to prove his worth with a series of comical mishaps."),
            MovieData(title: "Homeward Bound: The Incredible Journey", year: 1993, ageGroup: .preschoolers, genre: "Family", emoji: "🐕", streamingServices: ["Disney+"], rating: 4.4, notes: "Three pets journey through the wilderness to find their owners."),
            MovieData(title: "The Red Balloon", year: 1956, ageGroup: .preschoolers, genre: "Short", emoji: "🎈", streamingServices: ["The Criterion Channel", "Max"], rating: 4.3, notes: "A young boy in Paris befriends a sentient red balloon."),
            MovieData(title: "My Neighbor Totoro", year: 1988, ageGroup: .preschoolers, genre: "Animation", emoji: "🌳", streamingServices: ["Max"], rating: 4.8, notes: "Two young sisters discover a world of friendly forest spirits in postwar rural Japan."),
            MovieData(title: "The Adventures of Prince Achmed", year: 1926, ageGroup: .preschoolers, genre: "Animation", emoji: "🧞", streamingServices: ["Max", "Kanopy"], rating: 4.0, notes: "The oldest surviving animated feature film, based on 'One Thousand and One Nights.'"),
            MovieData(title: "The Land Before Time", year: 1988, ageGroup: .preschoolers, genre: "Animation", emoji: "🦕", streamingServices: ["Netflix"], rating: 4.2, notes: "An orphaned brontosaurus teams up with other young dinosaurs to find the Great Valley."),
            MovieData(title: "The Colours", year: 1976, ageGroup: .preschoolers, genre: "Short", emoji: "🎨", streamingServices: ["YouTube"], rating: 3.5, notes: "A short, colorful animated film."),
            MovieData(title: "Father and Daughter", year: 2000, ageGroup: .preschoolers, genre: "Short", emoji: "🚲", streamingServices: ["YouTube"], rating: 4.3, notes: "A daughter's life is chronicled through the seasons as she waits for her father's return."),
            MovieData(title: "Microcosmos", year: 1996, ageGroup: .preschoolers, genre: "Documentary", emoji: "🐞", streamingServices: ["The Criterion Channel"], rating: 4.1, notes: "A documentary exploring the hidden world of insects."),
            MovieData(title: "Dunston Checks In", year: 1996, ageGroup: .preschoolers, genre: "Family", emoji: "🐒", streamingServices: ["Max"], rating: 3.2, notes: "An orangutan causes chaos in a luxury hotel."),
            MovieData(title: "Hilda and the Mountain King", year: 2021, ageGroup: .preschoolers, genre: "Animation", emoji: "🏔️", streamingServices: ["Netflix"], rating: 4.5, notes: "Hilda wakes up in the body of a troll and must find her way home."),
            MovieData(title: "Robin Robin", year: 2021, ageGroup: .preschoolers, genre: "Short", emoji: "🐦", streamingServices: ["Netflix"], rating: 4.0, notes: "A robin raised by mice questions where she belongs."),
            MovieData(title: "Moomin and Midsummer Madness", year: 2008, ageGroup: .preschoolers, genre: "Animation", emoji: "🌊", streamingServices: ["Prime Video"], rating: 3.9, notes: "The Moomin family finds shelter in a floating theatre after a flood."),
            MovieData(title: "The Fox and the Hound", year: 1981, ageGroup: .preschoolers, genre: "Animation", emoji: "🦊", streamingServices: ["Disney+"], rating: 4.2, notes: "A story of an unlikely friendship between a fox and a hound."),
            MovieData(title: "The Snowman", year: 1982, ageGroup: .preschoolers, genre: "Short", emoji: "☃️", streamingServices: ["YouTube"], rating: 4.4, notes: "A boy's snowman comes to life on Christmas Eve."),
            MovieData(title: "The Cat Returns", year: 2002, ageGroup: .preschoolers, genre: "Animation", emoji: "🐈", streamingServices: ["Max"], rating: 4.1, notes: "A high school girl discovers she can talk to cats and is taken to the Cat Kingdom."),
            MovieData(title: "Charlotte’s Web", year: 1973, ageGroup: .preschoolers, genre: "Animation", emoji: "🕷️", streamingServices: ["Prime Video", "Paramount+"], rating: 4.0, notes: "A pig named Wilbur is saved from slaughter by a clever spider named Charlotte."),
            MovieData(title: "Spirit: Stallion of the Cimarron", year: 2002, ageGroup: .preschoolers, genre: "Animation", emoji: "🐎", streamingServices: ["Netflix", "Peacock"], rating: 4.3, notes: "A wild stallion's journey through the untamed American frontier."),
            MovieData(title: "Shaun the Sheep Movie", year: 2015, ageGroup: .preschoolers, genre: "Animation", emoji: "🐑", streamingServices: ["Netflix"], rating: 4.2, notes: "When Shaun decides to take the day off, he gets a little more action than he bargained for."),
            MovieData(title: "The Wrong Trousers", year: 1993, ageGroup: .preschoolers, genre: "Short", emoji: "👖", streamingServices: ["Prime Video"], rating: 4.6, notes: "Wallace and Gromit take in a penguin lodger who is not what he seems."),
            MovieData(title: "A Grand Day Out", year: 1989, ageGroup: .preschoolers, genre: "Short", emoji: "🚀", streamingServices: ["Prime Video"], rating: 4.2, notes: "Wallace and Gromit fly to the moon in search of cheese."),
            MovieData(title: "A Close Shave", year: 1995, ageGroup: .preschoolers, genre: "Short", emoji: "🐏", streamingServices: ["Prime Video"], rating: 4.5, notes: "Wallace and Gromit get entangled in a sheep-rustling scheme."),
            MovieData(title: "Donald in Mathmagic Land", year: 1959, ageGroup: .preschoolers, genre: "Short", emoji: "🔢", streamingServices: ["Disney+"], rating: 4.1, notes: "Donald Duck learns about the practical uses of mathematics."),
            MovieData(title: "The Great Mouse Detective", year: 1986, ageGroup: .preschoolers, genre: "Animation", emoji: "🕵️", streamingServices: ["Disney+"], rating: 4.0, notes: "A mouse detective must thwart the plans of his arch-nemesis, Professor Ratigan."),
            MovieData(title: "La luna", year: 2011, ageGroup: .preschoolers, genre: "Short", emoji: "🌙", streamingServices: ["Disney+"], rating: 4.4, notes: "A young boy learns his family's unusual line of work, sweeping stars from the moon."),
            MovieData(title: "Bao", year: 2018, ageGroup: .preschoolers, genre: "Short", emoji: "🥟", streamingServices: ["Disney+"], rating: 4.2, notes: "An aging Chinese mom suffering from empty nest syndrome gets another chance at motherhood when one of her dumplings springs to life."),
            MovieData(title: "Panda! Go Panda!", year: 1972, ageGroup: .preschoolers, genre: "Animation", emoji: "🐼", streamingServices: ["Max"], rating: 3.8, notes: "A cheerful young girl befriends a baby panda and his father."),
            MovieData(title: "Synchromy", year: 1971, ageGroup: .preschoolers, genre: "Short", emoji: "⬜", streamingServices: ["The Criterion Channel"], rating: 3.7, notes: "An experimental film where the soundtrack is created by the shapes on the screen."),
            MovieData(title: "Tarantella", year: 1940, ageGroup: .preschoolers, genre: "Short", emoji: "🎶", streamingServices: ["YouTube"], rating: 3.6, notes: "An abstract animation set to the music of a tarantella."),
            MovieData(title: "An Optical Poem", year: 1938, ageGroup: .preschoolers, genre: "Short", emoji: "🔵", streamingServices: ["YouTube"], rating: 3.8, notes: "An abstract film featuring paper cut-outs dancing to the music of Franz Liszt."),
            MovieData(title: "Daybreak Express", year: 1953, ageGroup: .preschoolers, genre: "Short", emoji: "🚂", streamingServices: ["The Criterion Channel"], rating: 4.0, notes: "A short documentary showing a ride on a New York City elevated train, set to the music of Duke Ellington."),
            
            // Little Kids (5-7)
            MovieData(title: "Abominable", year: 2019, ageGroup: .littleKids, genre: "Animation", emoji: " Yeti", streamingServices: ["Hulu"], rating: 4.0, notes: "A teen and her friends embark on a quest to reunite a young Yeti with his family."),
            MovieData(title: "The Great Race", year: 1965, ageGroup: .littleKids, genre: "Comedy", emoji: "🏎️", streamingServices: ["Max"], rating: 3.9, notes: "A slapstick comedy about an epic car race from New York to Paris in the early 20th century."),
            MovieData(title: "Spy Kids", year: 2001, ageGroup: .littleKids, genre: "Action", emoji: "🕶️", streamingServices: ["Netflix"], rating: 3.8, notes: "Two young siblings become spies to save their ex-spy parents."),
            MovieData(title: "Mon Oncle", year: 1958, ageGroup: .littleKids, genre: "Comedy", emoji: "🏠", streamingServices: ["The Criterion Channel", "Max"], rating: 4.1, notes: "Monsieur Hulot contends with the absurdities of modern, mechanized life."),
            MovieData(title: "The Secret of Kells", year: 2009, ageGroup: .littleKids, genre: "Animation", emoji: "📜", streamingServices: ["Prime Video"], rating: 4.3, notes: "A young boy in a remote medieval outpost enters a world of Celtic mythology."),
            MovieData(title: "Ernest & Celestine", year: 2012, ageGroup: .littleKids, genre: "Animation", emoji: "🐻", streamingServices: ["Prime Video"], rating: 4.4, notes: "The story of an unlikely friendship between a bear and a mouse."),
            MovieData(title: "Balto", year: 1995, ageGroup: .littleKids, genre: "Animation", emoji: "🐺", streamingServices: ["Netflix"], rating: 4.1, notes: "A half-wolf, half-husky sled dog helps save children from a diphtheria epidemic."),
            MovieData(title: "The Point", year: 1971, ageGroup: .littleKids, genre: "Animation", emoji: "👉", streamingServices: ["Prime Video"], rating: 4.0, notes: "An animated fable about a boy banished from a land where everything has a point, because he doesn't."),
            MovieData(title: "The Little Rascals", year: 1994, ageGroup: .littleKids, genre: "Family", emoji: "👦", streamingServices: ["Netflix"], rating: 3.5, notes: "The adventures of a group of mischievous neighborhood kids."),
            MovieData(title: "Boy & the World", year: 2013, ageGroup: .littleKids, genre: "Animation", emoji: "🌎", streamingServices: ["Kanopy"], rating: 4.2, notes: "A little boy's journey to find his father takes him on an adventure through a fantastical world."),
            MovieData(title: "James and the Giant Peach", year: 1996, ageGroup: .littleKids, genre: "Animation", emoji: "🍑", streamingServices: ["Disney+"], rating: 4.0, notes: "An orphan has a magical adventure inside a giant peach with a group of insects."),
            MovieData(title: "Where Is the Friend's House?", year: 1987, ageGroup: .littleKids, genre: "Drama", emoji: "🏡", streamingServices: ["The Criterion Channel"], rating: 4.1, notes: "A young boy must return his friend's notebook that he took by mistake."),
            MovieData(title: "Cats Don't Dance", year: 1997, ageGroup: .littleKids, genre: "Animation", emoji: "😼", streamingServices: ["Prime Video"], rating: 3.9, notes: "A talented cat goes to Hollywood to pursue his dreams of stardom but faces prejudice from human actors."),
            MovieData(title: "Chicken Run", year: 2000, ageGroup: .littleKids, genre: "Animation", emoji: "🐔", streamingServices: ["Netflix", "Peacock"], rating: 4.1, notes: "A group of chickens plot a great escape from a farm."),
            MovieData(title: "The Brave Little Toaster", year: 1987, ageGroup: .littleKids, genre: "Animation", emoji: "🍞", streamingServices: ["Disney+"], rating: 4.0, notes: "A group of household appliances go on a quest to find their owner."),
            MovieData(title: "The Mighty Ducks", year: 1992, ageGroup: .littleKids, genre: "Family", emoji: "🏒", streamingServices: ["Disney+"], rating: 3.8, notes: "A self-centered lawyer is sentenced to community service coaching a hapless youth hockey team."),
            MovieData(title: "Kooky", year: 2010, ageGroup: .littleKids, genre: "Animation", emoji: "🧸", streamingServices: ["Prime Video"], rating: 3.7, notes: "A discarded teddy bear must find his way back home."),
            MovieData(title: "Little Fugitive", year: 1953, ageGroup: .littleKids, genre: "Drama", emoji: "🎠", streamingServices: ["The Criterion Channel"], rating: 4.0, notes: "A seven-year-old boy runs away to Coney Island after thinking he has killed his older brother."),
            MovieData(title: "The White Balloon", year: 1995, ageGroup: .littleKids, genre: "Drama", emoji: "🎈", streamingServices: ["The Criterion Channel"], rating: 4.1, notes: "A little girl's quest to buy a goldfish for the Iranian New Year."),
            MovieData(title: "FernGully: The Last Rainforest", year: 1992, ageGroup: .littleKids, genre: "Animation", emoji: "🌳", streamingServices: ["Prime Video"], rating: 3.9, notes: "The magical inhabitants of a rainforest fight to save their home from logging and pollution."),
            MovieData(title: "The Incredible Journey", year: 1963, ageGroup: .littleKids, genre: "Family", emoji: "🐾", streamingServices: ["Disney+"], rating: 4.0, notes: "The original live-action story of three pets journeying home through the Canadian wilderness."),
            MovieData(title: "Beethoven", year: 1992, ageGroup: .littleKids, genre: "Family", emoji: "🐶", streamingServices: ["Netflix"], rating: 3.4, notes: "A slobbering St. Bernard becomes the center of a family's life."),
            MovieData(title: "Zootopia", year: 2016, ageGroup: .littleKids, genre: "Animation", emoji: "🐰", streamingServices: ["Disney+"], rating: 4.5, notes: "In a city of anthropomorphic animals, a rookie bunny cop and a cynical con artist fox must work together to uncover a conspiracy."),
            MovieData(title: "The Rescuers Down Under", year: 1990, ageGroup: .littleKids, genre: "Animation", emoji: "🦅", streamingServices: ["Disney+"], rating: 4.0, notes: "Two mice from the Rescue Aid Society travel to Australia to save a boy from a poacher."),
            MovieData(title: "Ratatouille", year: 2007, ageGroup: .littleKids, genre: "Animation", emoji: "🐀", streamingServices: ["Disney+"], rating: 4.7, notes: "A rat who can cook makes an unusual alliance with a young kitchen worker at a famous restaurant."),
            MovieData(title: "Flushed Away", year: 2006, ageGroup: .littleKids, genre: "Animation", emoji: "🚽", streamingServices: ["Netflix"], rating: 3.8, notes: "A pampered pet mouse is flushed down the toilet and discovers a bustling world of sewer rats."),
            MovieData(title: "The Pirates! In an Adventure with Scientists!", year: 2012, ageGroup: .littleKids, genre: "Animation", emoji: "🏴‍☠️", streamingServices: ["Max"], rating: 4.0, notes: "An enthusiastic but less-than-successful pirate captain enters the Pirate of the Year competition."),
            MovieData(title: "Wallace & Gromit: The Curse of the Were-Rabbit", year: 2005, ageGroup: .littleKids, genre: "Animation", emoji: "🐇", streamingServices: ["Netflix"], rating: 4.3, notes: "Wallace and his dog Gromit set out to solve the mystery behind the garden sabotage that plagues their village."),
            MovieData(title: "Over the Moon", year: 2020, ageGroup: .littleKids, genre: "Animation", emoji: "🚀", streamingServices: ["Netflix"], rating: 3.9, notes: "A girl builds a rocket to the moon to prove the existence of a legendary Moon Goddess."),
            MovieData(title: "Corpse Bride", year: 2005, ageGroup: .littleKids, genre: "Animation", emoji: "💀", streamingServices: ["Max"], rating: 4.2, notes: "A shy groom practicing his wedding vows inadvertently marries a deceased young woman."),
            MovieData(title: "Zenon: Girl of the 21st Century", year: 1999, ageGroup: .littleKids, genre: "Sci-Fi", emoji: "🛰️", streamingServices: ["Disney+"], rating: 3.6, notes: "A curious teenager living on a space station in 2049 gets into trouble."),
            MovieData(title: "Atlantis: The Lost Empire", year: 2001, ageGroup: .littleKids, genre: "Animation", emoji: "💎", streamingServices: ["Disney+"], rating: 4.0, notes: "A young adventurer joins a group of explorers to find the legendary lost city of Atlantis."),
            MovieData(title: "Meet the Robinsons", year: 2007, ageGroup: .littleKids, genre: "Animation", emoji: "🤖", streamingServices: ["Disney+"], rating: 4.0, notes: "A boy inventor meets a mysterious stranger who whisks him away to the future."),
            MovieData(title: "Son of Flubber", year: 1963, ageGroup: .littleKids, genre: "Family", emoji: "🧪", streamingServices: ["Disney+"], rating: 3.7, notes: "A professor's new invention, 'dry rain,' causes more comical chaos."),
            MovieData(title: "The Secret of NIMH", year: 1982, ageGroup: .littleKids, genre: "Animation", emoji: "🐭", streamingServices: ["Prime Video"], rating: 4.2, notes: "A widowed field mouse must move her family before the farmer's plow arrives, seeking help from a colony of super-intelligent rats."),
            MovieData(title: "All Dogs Go to Heaven", year: 1989, ageGroup: .littleKids, genre: "Animation", emoji: "😇", streamingServices: ["Max"], rating: 3.9, notes: "A canine con artist escapes from heaven to get revenge on his killer."),
            MovieData(title: "An American Tail", year: 1986, ageGroup: .littleKids, genre: "Animation", emoji: "移民", streamingServices: ["Netflix"], rating: 4.0, notes: "A young Russian mouse gets separated from his family while they are emigrating to the United States."),
            MovieData(title: "Anastasia", year: 1997, ageGroup: .littleKids, genre: "Animation", emoji: "👑", streamingServices: ["Disney+"], rating: 4.1, notes: "The last surviving child of the Russian Royal Family joins two con men to reunite with her grandmother, the Dowager Empress."),
            MovieData(title: "Robin Hood", year: 1973, ageGroup: .littleKids, genre: "Animation", emoji: "🏹", streamingServices: ["Disney+"], rating: 4.2, notes: "The classic story of the heroic outlaw portrayed with anthropomorphic animals."),
            MovieData(title: "Pom Poko", year: 1994, ageGroup: .littleKids, genre: "Animation", emoji: "🦝", streamingServices: ["Max"], rating: 4.0, notes: "A community of magical, shape-shifting raccoons struggles to prevent their forest home from being destroyed by urban development."),
            MovieData(title: "Kiki's Delivery Service", year: 1989, ageGroup: .littleKids, genre: "Animation", emoji: "🧹", streamingServices: ["Max"], rating: 4.4, notes: "A young witch moves to a new town and uses her flying ability to earn a living."),
            MovieData(title: "Rain Dance", year: 1990, ageGroup: .littleKids, genre: "Short", emoji: "🌧️", streamingServices: ["YouTube"], rating: 3.5, notes: "A colorful short film about a dance to bring rain."),
            MovieData(title: "The Birth of the Robot", year: 1936, ageGroup: .littleKids, genre: "Short", emoji: "🤖", streamingServices: ["YouTube"], rating: 3.6, notes: "An early animated short depicting the creation of a robot."),

            // Big Kids (8-9)
            MovieData(title: "The Borrowers", year: 1997, ageGroup: .bigKids, genre: "Family", emoji: "🏠", streamingServices: ["Peacock"], rating: 3.5, notes: "A family of tiny people who live in the walls of a house must save their home from an evil real estate developer."),
            MovieData(title: "Pather Panchali", year: 1955, ageGroup: .bigKids, genre: "Drama", emoji: "🚂", streamingServices: ["The Criterion Channel", "Max"], rating: 4.5, notes: "The life of a young boy, Apu, in a small village in Bengal."),
            MovieData(title: "Shaolin Soccer", year: 2001, ageGroup: .bigKids, genre: "Comedy", emoji: "⚽", streamingServices: ["Paramount+"], rating: 4.1, notes: "A young Shaolin monk reunites his five brothers to apply their martial arts skills to soccer."),
            MovieData(title: "The Sandlot", year: 1993, ageGroup: .bigKids, genre: "Family", emoji: "⚾", streamingServices: ["Disney+"], rating: 4.2, notes: "A new kid in town is taken under the wing of a young baseball prodigy and his team."),
            MovieData(title: "The Gold Rush", year: 1925, ageGroup: .bigKids, genre: "Comedy", emoji: "⭐", streamingServices: ["The Criterion Channel", "Max"], rating: 4.4, notes: "A lone prospector ventures into Alaska looking for gold during the Klondike Gold Rush."),
            MovieData(title: "The New Adventures of Pippi Longstocking", year: 1988, ageGroup: .bigKids, genre: "Family", emoji: "👧", streamingServices: ["Tubi"], rating: 3.2, notes: "The adventures of a spirited young girl with superhuman strength."),
            MovieData(title: "Good Burger", year: 1997, ageGroup: .bigKids, genre: "Comedy", emoji: "🍔", streamingServices: ["Netflix", "Paramount+"], rating: 3.4, notes: "Two dim-witted teenagers are forced to save the fast-food restaurant where they work."),
            MovieData(title: "Willow", year: 1988, ageGroup: .bigKids, genre: "Fantasy", emoji: "🧙", streamingServices: ["Disney+"], rating: 4.1, notes: "A young farmer is chosen to protect a special baby from an evil queen."),
            MovieData(title: "A Goofy Movie", year: 1995, ageGroup: .bigKids, genre: "Animation", emoji: "🗺️", streamingServices: ["Disney+"], rating: 4.0, notes: "Goofy tries to bond with his son, Max, on a cross-country fishing trip."),
            MovieData(title: "Drop Dead Fred", year: 1991, ageGroup: .bigKids, genre: "Comedy", emoji: "🤪", streamingServices: ["Max"], rating: 3.5, notes: "A young woman's imaginary friend from childhood returns to wreak havoc in her adult life."),
            MovieData(title: "A Little Princess", year: 1995, ageGroup: .bigKids, genre: "Drama", emoji: "👑", streamingServices: ["Hulu"], rating: 4.3, notes: "A young girl is relegated to a life of servitude in a New York boarding school by the headmistress after receiving news that her father was killed in action."),
            MovieData(title: "The Secret of Roan Inish", year: 1994, ageGroup: .bigKids, genre: "Fantasy", emoji: "🦭", streamingServices: ["Prime Video"], rating: 4.2, notes: "A young Irish girl uncovers a family secret involving selkies, mythical creatures that are part human, part seal."),
            MovieData(title: "Flubber", year: 1997, ageGroup: .bigKids, genre: "Family", emoji: "🧪", streamingServices: ["Disney+"], rating: 3.3, notes: "An absent-minded professor discovers a rubber-like substance that gains kinetic energy as it bounces."),
            MovieData(title: "Babe: Pig in the City", year: 1998, ageGroup: .bigKids, genre: "Family", emoji: "🐷", streamingServices: ["Netflix"], rating: 3.7, notes: "Babe, the pig, must travel to the big city to save the farm."),
            MovieData(title: "Whistle Down the Wind", year: 1961, ageGroup: .bigKids, genre: "Drama", emoji: "⛪", streamingServices: ["The Criterion Channel"], rating: 4.1, notes: "A group of children mistake an escaped convict for Jesus Christ."),
            MovieData(title: "Auntie Mame", year: 1958, ageGroup: .bigKids, genre: "Comedy", emoji: "🍸", streamingServices: ["Max"], rating: 4.2, notes: "An orphan goes to live with his eccentric aunt in New York City."),
            MovieData(title: "My Life as a Dog", year: 1985, ageGroup: .bigKids, genre: "Drama", emoji: "🐶", streamingServices: ["The Criterion Channel"], rating: 4.2, notes: "A young boy is sent to live with his relatives in a rural town in Sweden."),
            MovieData(title: "I Wish", year: 2011, ageGroup: .bigKids, genre: "Drama", emoji: "🚄", streamingServices: ["Kanopy"], rating: 4.0, notes: "Two brothers separated by their parents' divorce believe that a miracle will happen when two bullet trains pass each other at top speed."),
            MovieData(title: "Like Mike", year: 2002, ageGroup: .bigKids, genre: "Family", emoji: "🏀", streamingServices: ["Disney+"], rating: 3.5, notes: "A young orphan becomes an NBA superstar after finding a magical pair of sneakers."),
            MovieData(title: "The Cave of the Yellow Dog", year: 2005, ageGroup: .bigKids, genre: "Drama", emoji: "🐕‍🦺", streamingServices: ["Kanopy"], rating: 4.0, notes: "A young girl in a nomadic Mongolian family finds a stray dog and must convince her father to let her keep it."),
            MovieData(title: "Free Willy", year: 1993, ageGroup: .bigKids, genre: "Family", emoji: "🐋", streamingServices: ["Netflix"], rating: 3.8, notes: "A boy risks everything to save a captive killer whale."),
            MovieData(title: "Who Framed Roger Rabbit", year: 1988, ageGroup: .bigKids, genre: "Animation", emoji: "🐰", streamingServices: ["Disney+"], rating: 4.3, notes: "A toon-hating detective is a cartoon rabbit's only hope to prove his innocence when he is accused of murder."),
            MovieData(title: "Creature Comforts", year: 1989, ageGroup: .bigKids, genre: "Short", emoji: "🐅", streamingServices: ["YouTube"], rating: 4.1, notes: "A series of interviews with zoo animals about their living conditions."),
            MovieData(title: "The Young Girls of Rochefort", year: 1967, ageGroup: .bigKids, genre: "Musical", emoji: "🎶", streamingServices: ["The Criterion Channel", "Max"], rating: 4.2, notes: "Twin sisters, a musician and a dancer, dream of finding love and fame in Paris."),
            MovieData(title: "The Wiz", year: 1978, ageGroup: .bigKids, genre: "Musical", emoji: "👠", streamingServices: ["Netflix"], rating: 3.5, notes: "A modern retelling of 'The Wizard of Oz' with an all-Black cast."),
            MovieData(title: "An American in Paris", year: 1951, ageGroup: .bigKids, genre: "Musical", emoji: "🎨", streamingServices: ["Max"], rating: 4.1, notes: "An American ex-GI stays in post-war Paris to become a painter and falls for a beautiful French girl."),
            MovieData(title: "Cool Runnings", year: 1993, ageGroup: .bigKids, genre: "Family", emoji: "🛷", streamingServices: ["Disney+"], rating: 4.0, notes: "The true story of the first Jamaican bobsled team to compete in the Winter Olympics."),
            MovieData(title: "Bedknobs and Broomsticks", year: 1971, ageGroup: .bigKids, genre: "Family", emoji: "🪄", streamingServices: ["Disney+"], rating: 4.1, notes: "An apprentice witch and three kids help a cynical magician find a magic spell to aid the British war effort."),
            MovieData(title: "Treasure Planet", year: 2002, ageGroup: .bigKids, genre: "Animation", emoji: "🪐", streamingServices: ["Disney+"], rating: 4.1, notes: "A sci-fi retelling of 'Treasure Island' where a cabin boy embarks on a journey across the universe."),
            MovieData(title: "Titan A.E.", year: 2000, ageGroup: .bigKids, genre: "Animation", emoji: "🚀", streamingServices: ["Max"], rating: 3.9, notes: "A young man learns he has to find a hidden Earth-like planet before an enemy alien species does in order to save humanity."),
            MovieData(title: "The Rescuers", year: 1977, ageGroup: .bigKids, genre: "Animation", emoji: "💎", streamingServices: ["Disney+"], rating: 4.0, notes: "Two mice from the Rescue Aid Society must save a kidnapped orphan girl."),
            MovieData(title: "Lupin the Third: The Castle of Cagliostro", year: 1979, ageGroup: .bigKids, genre: "Animation", emoji: "🏰", streamingServices: ["Netflix"], rating: 4.3, notes: "A master thief and his gang try to rescue a princess and uncover a massive counterfeiting operation."),
            MovieData(title: "Howl's Moving Castle", year: 2004, ageGroup: .bigKids, genre: "Animation", emoji: "🏰", streamingServices: ["Max"], rating: 4.6, notes: "A young woman is cursed with an old body by a spiteful witch and her only hope of breaking the spell lies with a self-indulgent, insecure young wizard."),
            MovieData(title: "Castle in the Sky", year: 1986, ageGroup: .bigKids, genre: "Animation", emoji: "✈️", streamingServices: ["Max"], rating: 4.4, notes: "A young boy and a girl with a magic crystal must race against pirates and foreign agents to find a legendary floating castle."),
            MovieData(title: "Spirited Away", year: 2001, ageGroup: .bigKids, genre: "Animation", emoji: "🏮", streamingServices: ["Max"], rating: 4.9, notes: "During her family's move to the suburbs, a sullen 10-year-old girl wanders into a world ruled by gods, witches, and spirits, and where humans are changed into beasts."),
            MovieData(title: "Entr'acte", year: 1924, ageGroup: .bigKids, genre: "Short", emoji: "🎬", streamingServices: ["YouTube"], rating: 3.9, notes: "A surrealist, Dadaist short film made to be shown between the acts of a ballet."),
            MovieData(title: "Loose Corner", year: 1986, ageGroup: .bigKids, genre: "Short", emoji: "🔩", streamingServices: ["YouTube"], rating: 3.5, notes: "An abstract animated short film."),
            MovieData(title: "Of Stars and Men", year: 1961, ageGroup: .bigKids, genre: "Short", emoji: "⭐", streamingServices: ["YouTube"], rating: 4.0, notes: "An animated film that explores humanity's place in the universe."),
            MovieData(title: "Bluebeard", year: 1936, ageGroup: .bigKids, genre: "Short", emoji: "🔑", streamingServices: ["YouTube"], rating: 3.8, notes: "A claymation short based on the classic fairytale."),
            MovieData(title: "Happy People: A Year in the Taiga", year: 2010, ageGroup: .bigKids, genre: "Documentary", emoji: "🌲", streamingServices: ["Kanopy"], rating: 4.2, notes: "A documentary about the life of hunters and trappers in the Siberian wilderness."),

            // Tweens (10-12)
            MovieData(title: "Young Frankenstein", year: 1974, ageGroup: .tweens, genre: "Comedy", emoji: "🧠", streamingServices: ["Max"], rating: 4.5, notes: "A comedic masterpiece that parodies classic horror films."),
            MovieData(title: "Kes", year: 1969, ageGroup: .tweens, genre: "Drama", emoji: "🐦", streamingServices: ["The Criterion Channel"], rating: 4.3, notes: "A troubled working-class boy finds solace in training a kestrel."),
            MovieData(title: "The Triplets of Belleville", year: 2003, ageGroup: .tweens, genre: "Animation", emoji: "🎶", streamingServices: ["Kanopy"], rating: 4.2, notes: "An elderly woman and her dog enlist the help of a trio of jazz-era divas to rescue her kidnapped grandson."),
            MovieData(title: "Into the West", year: 1992, ageGroup: .tweens, genre: "Fantasy", emoji: "🐴", streamingServices: ["Disney+"], rating: 4.0, notes: "Two young boys from a Dublin slum escape their grim lives on a magical white horse."),
            MovieData(title: "Zazie dans le Métro", year: 1960, ageGroup: .tweens, genre: "Comedy", emoji: "🚇", streamingServices: ["The Criterion Channel", "Max"], rating: 4.1, notes: "A cheeky provincial girl's chaotic 48-hour visit to her uncle in Paris."),
            MovieData(title: "Police Story", year: 1985, ageGroup: .tweens, genre: "Action", emoji: "👮", streamingServices: ["The Criterion Channel", "Max"], rating: 4.2, notes: "A virtuous Hong Kong cop must clear his name after being framed for murder."),
            MovieData(title: "Hairspray", year: 1988, ageGroup: .tweens, genre: "Comedy", emoji: "💇‍♀️", streamingServices: ["Max"], rating: 4.0, notes: "A bubbly, overweight teenager becomes a local celebrity on a Baltimore dance show in the 1960s."),
            MovieData(title: "Hero", year: 2002, ageGroup: .tweens, genre: "Action", emoji: "⚔️", streamingServices: ["Max"], rating: 4.4, notes: "A visually stunning martial arts epic about a nameless man who recounts his victories over three assassins to the King of Qin."),
            MovieData(title: "Village of the Damned", year: 1960, ageGroup: .tweens, genre: "Horror", emoji: "👽", streamingServices: ["The Criterion Channel"], rating: 4.1, notes: "A British village's women mysteriously become pregnant and give birth to sinister, telepathic children."),
            MovieData(title: "The Dirt Bike Kid", year: 1985, ageGroup: .tweens, genre: "Family", emoji: "🏍️", streamingServices: ["Tubi"], rating: 3.1, notes: "A boy buys a magical dirt bike that helps him stand up to a local banker trying to tear down his friend's hot dog stand."),
            MovieData(title: "Bend It Like Beckham", year: 2002, ageGroup: .tweens, genre: "Comedy", emoji: "⚽", streamingServices: ["Disney+"], rating: 4.0, notes: "The daughter of orthodox Sikh rebels against her parents' traditionalism and joins a local women's soccer team."),
            MovieData(title: "Small Soldiers", year: 1998, ageGroup: .tweens, genre: "Action", emoji: "💥", streamingServices: ["Netflix"], rating: 3.7, notes: "A line of action figures with military-grade AI start a war in a quiet suburban neighborhood."),
            MovieData(title: "Peppermint Soda", year: 1977, ageGroup: .tweens, genre: "Drama", emoji: "🥤", streamingServices: ["The Criterion Channel"], rating: 4.0, notes: "A semi-autobiographical coming-of-age story about two sisters in 1960s France."),
            MovieData(title: "The Day the Earth Stood Still", year: 1951, ageGroup: .tweens, genre: "Sci-Fi", emoji: "🤖", streamingServices: ["Max"], rating: 4.3, notes: "An alien lands and tells the people of Earth that they must live peacefully or be destroyed as a danger to other planets."),
            MovieData(title: "My Life as a Zucchini", year: 2016, ageGroup: .tweens, genre: "Animation", emoji: "🥒", streamingServices: ["Kanopy"], rating: 4.3, notes: "A stop-motion animated film about a young boy who is sent to a foster home with other orphans his age."),
            MovieData(title: "Whale Rider", year: 2002, ageGroup: .tweens, genre: "Drama", emoji: "🐋", streamingServices: ["Netflix"], rating: 4.2, notes: "A contemporary story of love, rejection and triumph as a young Maori girl fights to fulfill a destiny her grandfather refuses to recognize."),
            MovieData(title: "Wolf Children", year: 2012, ageGroup: .tweens, genre: "Animation", emoji: "🐺", streamingServices: ["Prime Video"], rating: 4.5, notes: "A college student falls in love with a wolf man and raises their two half-wolf, half-human children after he dies."),
            MovieData(title: "Holes", year: 2003, ageGroup: .tweens, genre: "Family", emoji: "🕳️", streamingServices: ["Disney+"], rating: 4.0, notes: "A wrongfully convicted boy is sent to a brutal desert detention camp where he is forced to dig holes."),
            MovieData(title: "Crooklyn", year: 1994, ageGroup: .tweens, genre: "Drama", emoji: "🏠", streamingServices: ["Hulu"], rating: 4.0, notes: "A semi-autobiographical film from Spike Lee about a young girl growing up in Brooklyn in the 1970s."),
            MovieData(title: "The Wonders", year: 2014, ageGroup: .tweens, genre: "Drama", emoji: "🐝", streamingServices: ["Kanopy"], rating: 3.9, notes: "The story of a family of beekeepers living in the Tuscan countryside."),
            MovieData(title: "Best in Show", year: 2000, ageGroup: .tweens, genre: "Comedy", emoji: "🏆", streamingServices: ["Hulu"], rating: 4.2, notes: "A mockumentary that follows five eccentric owners of prized dogs at a prestigious dog show."),
            MovieData(title: "Linda Linda Linda", year: 2005, ageGroup: .tweens, genre: "Comedy", emoji: "🎸", streamingServices: ["YouTube"], rating: 4.1, notes: "A group of Japanese high school girls form a rock band for their school's cultural festival."),
            MovieData(title: "Starstruck", year: 1982, ageGroup: .tweens, genre: "Musical", emoji: "⭐", streamingServices: ["The Criterion Channel"], rating: 3.8, notes: "An Australian New Wave musical comedy about a young woman who wants to be a pop star."),
            MovieData(title: "True Stories", year: 1986, ageGroup: .tweens, genre: "Comedy", emoji: "🤠", streamingServices: ["The Criterion Channel"], rating: 4.0, notes: "A musical mockumentary directed by David Byrne of the Talking Heads, set in a fictional Texas town."),
            MovieData(title: "School of Rock", year: 2003, ageGroup: .tweens, genre: "Comedy", emoji: "🤘", streamingServices: ["Netflix", "Paramount+"], rating: 4.1, notes: "After being kicked out of his rock band, a struggling musician poses as a substitute teacher and forms a band with his fifth-grade students."),
            MovieData(title: "Smart House", year: 1999, ageGroup: .tweens, genre: "Sci-Fi", emoji: "🏠", streamingServices: ["Disney+"], rating: 3.7, notes: "A teenager wins a fully automated, computerized house that begins to take on a life of its own."),
            MovieData(title: "The Rocketeer", year: 1991, ageGroup: .tweens, genre: "Action", emoji: "🚀", streamingServices: ["Disney+"], rating: 3.9, notes: "A young pilot discovers a top-secret jetpack and becomes a flying hero."),
            MovieData(title: "Brink!", year: 1998, ageGroup: .tweens, genre: "Drama", emoji: "🛹", streamingServices: ["Disney+"], rating: 3.8, notes: "A high school inline skater and his friends clash with a corporate-sponsored skate team."),
            MovieData(title: "The Tale of The Princess Kaguya", year: 2013, ageGroup: .tweens, genre: "Animation", emoji: "🎋", streamingServices: ["Netflix"], rating: 4.5, notes: "A tiny girl found inside a stalk of bamboo grows into an exquisite young lady who enthralls all who encounter her."),
            MovieData(title: "The Wind Rises", year: 2013, ageGroup: .tweens, genre: "Animation", emoji: "✈️", streamingServices: ["Max"], rating: 4.3, notes: "A look at the life of Jiro Horikoshi, the man who designed Japanese fighter planes during World War II."),
            MovieData(title: "Dreams", year: 1990, ageGroup: .tweens, genre: "Fantasy", emoji: "💭", streamingServices: ["The Criterion Channel"], rating: 4.2, notes: "A collection of short films based on the actual dreams of director Akira Kurosawa."),
            MovieData(title: "Hairat", year: 2017, ageGroup: .tweens, genre: "Short", emoji: "🌊", streamingServices: ["YouTube"], rating: 4.0, notes: "A short documentary about a man who dives into the turbulent waters of a flooded river in India."),
            MovieData(title: "Yard Work Is Hard Work", year: 2008, ageGroup: .tweens, genre: "Short", emoji: "🌱", streamingServices: ["YouTube"], rating: 3.5, notes: "An animated short about the trials and tribulations of yard work."),
            MovieData(title: "The Mirror", year: 1997, ageGroup: .tweens, genre: "Short", emoji: "🪞", streamingServices: ["YouTube"], rating: 3.9, notes: "A surreal animated short film.")
        ]
    }
}
