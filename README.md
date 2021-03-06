# WeatherApp

Tech stack:
- Network requests (API: https://openweathermap.org/)
- CoreData with 2 contexts (main and private)
- UIKit 12+
- SwiftGen, SwiftLint
- Ru and En localizations

Приложение написано в качестве тестового задания.

Исходный текст задания:
Есть сервис прогноза погоды https://openweathermap.org/api
Написать приложение прогноза погоды.
1. Список пользовательских городов, при первом запуске приложения, список должен
содержать город пользователя приложения. Пользователь может добавить любое
произвольное кол-во городов. В списке, около каждого города должна показываться
погода на данное время.
2. При выборе конкретного населенного пункта должен открываться экран с подробным
прогнозом на 5 дней
3. Для хранения списка городов нужно использовать CoreData
4. Предусмотреть автоматическое обновления текущей погоды (те данных на первом
экране) не реже, чем раз в час
5. Все запросы не должны выполняться в главном потоке

Итог:
Для выполнения задачи, соискатель должен потратить минимальное кол-во времени на
изучение стороннего сервиса на английском языке, зарегистрироваться там получить
идентификатор для запросов.
Построить сетевой уровень для отправки запроса и получения данных
Раскрасить JSON
Сохранить данные в CoreData (ну или еще в какую-нить бд)
Получения и обработку данных в многопоточном режиме
Работа с геолокацией
Нарисовать минимальный UI на базе TableView на первом экране и на экране подробного
прогноза погоды, для добавления города просто экран с несколькими полями ввода

![image](https://user-images.githubusercontent.com/5717020/144679407-d73e87c1-bdd2-4e7b-9acf-47e92f0ddf09.png)
![image](https://user-images.githubusercontent.com/5717020/144679260-3fa8cfaa-24c0-4f8a-8d12-de6952ab4ac0.png)
![image](https://user-images.githubusercontent.com/5717020/144679353-2af58767-1340-44ee-af7f-d542409dc38b.png)
![image](https://user-images.githubusercontent.com/5717020/144679452-095d4bae-63a4-4b16-9477-3f8b83144b05.png)


