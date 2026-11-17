# FMXPixie

> **DLL на Delphi / FireMonkey для создания полноценных интерфейсов установщиков с помощью Inno Setup.**

FMXPixie предоставляет Windows-приложениям доступ к формам FireMonkey, элементам управления, компонентам отрисовки и вспомогательным службам через DLL и соответствующий интерфейс Inno Setup Pascal Script.

Основной компонент отрисовки — HTML/CSS-движок, написанный на Pascal. FMXPixie не использует Chromium, WebView2 или отдельный процесс браузера. Кроме того, проект предоставляет работу с SVG и Markdown, пользовательскую отрисовку, элементы TagBar, воспроизведение MP3, обработку устройств ввода и интеграцию с Windows.

FMXPixie предназначен прежде всего для Inno Setup. Процесс установщика загружает DLL, а окно FMX создаётся как отдельное окно верхнего уровня. HWND хост-приложения передаётся методу создания FMX-формы; интерфейс FMX не является дочерним элементом управления Inno Setup.

Репозиторий содержит обе стороны интеграции:

- `FMXPixie.dpr` и модули Delphi, из которых собирается DLL.
- [`FMXPixieHandle.iss`](Examples/Modules/FMXPixieHandle.iss) — файл с объявлениями интерфейсов, типов, обратных вызовов и импортируемых функций DLL для Inno Setup Pascal Script.

## Возможности

- **Отрисовка HTML и CSS** — загрузка HTML из строки или файла, установка базового URL и пользовательских CSS-стилей, работа с обёртками документа и DOM-элементов, поиск элементов с помощью CSS-селекторов, пакетное обновление DOM, обработка ссылок и событий элементов, управление масштабом и прокруткой, экспорт отрисованного содержимого в PDF или PNG.
- **Взаимодействие и переходы CSS** — состояния hover, визуальные эффекты, примеры переходов и изменения компоновки.
- **Отрисовка SVG** — отображение SVG через специализированный FMX-компонент с настройками выравнивания и размеров.
- **Отрисовка Markdown** — отображение Markdown с помощью парсера Pixie Markdown и FMX-компонента.
- **PaintBox** — рисование контуров и фигур, заливка и обводка, отрисовка изображений через API на основе Canvas.
- **TagBar** — интерактивные теги с настраиваемыми цветами, значками, отметкой выбора, событиями редактирования и прокруткой.
- **Аудио MP3** — FMX-обёртка аудиоплеера с управлением воспроизведением и громкостью.
- **Устройства ввода** — клавиатура, мышь и игровые контроллеры через включённую в репозиторий Windows-версию FMXInput; поддерживаются привязки действий, опрос состояния, перехват и переназначение, профили и вибрация, если это поддерживается устройством и используемым backend.
- **Видеофон** — компонент `FVideoBackground` на основе Media Foundation, использующий API-декларации MfPack через интеграционный слой `TVideoPlayer`.
- **Интеграция с Windows** — FMX-формы, вспомогательные средства оформления окон на основе DWM, утилиты окон, поддержка курсора, сведения о системе и накопителях.
- **Вспомогательные службы** — таймеры, секундомер, работа с текстовыми файлами и форматирование размеров и частот.

Публичные объявления Pascal Script в [`FMXPixieHandle.iss`](Examples/Modules/FMXPixieHandle.iss) являются основным источником информации об экспортируемых именах, идентификаторах интерфейсов, сигнатурах методов, типах параметров и обратных вызовах.

## Примеры

В каталоге [`Examples/`](Examples/) находятся 20 скриптов Inno Setup. Это исходные демонстрационные примеры и тесты, а не предварительно собранные установщики.

### Примеры интерфейсов приложений

- [Main Demo](<Examples/FMXPixie - Form Values.iss>) — демонстрация формы FMX и взаимодействия со значениями элементов управления.
- [MORROW / Object Archive](<Examples/FMXPixie - Morrow.iss>) — интерфейс каталога в стиле приложения с карточками, фильтрацией и обновлением DOM.
- [FluentInstaller](<Examples/FMXPixie - Installer Settings.iss>) — композиция интерфейса в стиле установщика.
- [MELE Launcher](<Examples/FMXPixie - MELE Launcher.iss>) — интерфейс в стиле лаунчера.
- [AeroGlass Lab](<Examples/FMXPixie - AeroGlass Lab.iss>) — эксперименты с внешним видом окна и DWM.
- [Wrapper Integration Lab](<Examples/FMXPixie - Wrapper Integration Lab.iss>) — расширенная демонстрация API-обёртки Pascal Script.

### Примеры компонентов

- [SVGView](<Examples/FMXPixie - SVGView.iss>)
- [MarkdownView](<Examples/FMXPixie - MarkdownView.iss>)
- [PaintBox](<Examples/FMXPixie - PaintBox.iss>)
- [TagBar](<Examples/FMXPixie - TagBar Demo.iss>)
- [SpanControls](<Examples/FMXPixie - Select Option.iss>)
- [Component Size](<Examples/FMXPixie - Component Size Demo.iss>)
- [Hover Event Visual](<Examples/FMXPixie - Hover Event Visual.iss>)

### Аудио, видео и устройства ввода

- [AudioPlayer](<Examples/FMXPixie - AudioPlayer.iss>)
- [Volume Slider](<Examples/FMXPixie - AudioPlayer.iss>) — управление громкостью показано в примере AudioPlayer.
- [Gamepad Input](<Examples/FMXPixie - Gamepad Input.iss>)
- [VideoBackground](<Examples/FMXPixie - VideoBackground.iss>) — воспроизведение видео в FMX-форме с использованием Media Foundation.

### Тесты CSS и отрисовки

- [CSS Background Image Gradient](<Examples/FMXPixie - CSS Background Image Gradient Test.iss>)
- [CSS Box Shadow Transition](<Examples/FMXPixie - CSS Box Shadow Transition Test.iss>)
- [CSS Size/Layout Transition](<Examples/FMXPixie - CSS Size Layout Transition Test.iss>)
- [CSS Transition / DisplayLink](<Examples/FMXPixie - CSS Transition DisplayLink.iss>)

Вспомогательные ресурсы находятся в каталоге [`Examples/Files/`](Examples/Files/).

## Требования

- **Embarcadero RAD Studio 13.2 / Delphi с FireMonkey.** Включённый в репозиторий файл подключения указывает сборку компилятора `37.0.60952.8797`, RTM Update 2.
- **Windows, Win32 и Win64.** Проект настроен для сборки 32-разрядной и 64-разрядной DLL.
- **Inno Setup** — необходим для компиляции и запуска примеров `.iss`. Разрядность выбранной DLL должна соответствовать разрядности процесса Setup.
- Проект использует локальные исходники из `ThirdParty/FMXInput`, `ThirdParty/MfPack`, `Custom/AudioPlayer/Source` и `Custom/AudioPlayer/Dependencies/PCMAudio`; эти каталоги включены в пути поиска проекта.

Отдельная установка компонентов Pixie или FMXInput в палитру компонентов RAD Studio не требуется.

Перед распространением исходников или DLL ознакомьтесь с [`THIRD-PARTY-NOTICES.md`](THIRD-PARTY-NOTICES.md). Репозиторий содержит код с разными условиями лицензирования; корневая MIT-лицензия не распространяется на все файлы.

## Структура проекта

| Путь | Назначение |
| --- | --- |
| `FMXPixie.dpr` | Исходный файл проекта DLL, список модулей и суффиксы библиотек для разных архитектур. |
| `FMXPixie.dproj` | Настройки проекта RAD Studio. |
| [`Examples/Modules/FMXPixieHandle.iss`](Examples/Modules/FMXPixieHandle.iss) | Объявления интерфейсов и импортируемых внешних функций для Inno Setup. |
| `Forms/` | FMX-формы, вспомогательные средства DWM, поддержка курсора и утилиты Windows. |
| `FMX/` | Интеграция с системными возможностями FMX. |
| `Pixie/Common/` | Общие примитивы отрисовки, изображения, цвета, шрифты, SVG и поддержка WebP из движка Pixie. |
| `Pixie/HtmlView/` | Разбор HTML/CSS, компоновка, DOM, отрисовка и экспорт PDF. |
| `Pixie/Markdown/` | Парсер Markdown и интеграция с FMX-представлением. |
| `Pixie/SvgView/`, `Pixie/PaintBox/`, `Pixie/TagBar/` | Дополнительные средства отрисовки и элементы управления FMX. |
| `Custom/` | Обёртки FMXPixie, аудиоплеер, ввод, системная информация и вспомогательные модули. |
| `ThirdParty/FMXInput/` | Включённые в репозиторий исходники Windows-версии FMXInput и лицензия MIT. |
| `ThirdParty/MfPack/` | API-декларации Media Foundation, основанные на MfPack, и интеграционный модуль `TVideoPlayer`; лицензии и уведомления см. в `THIRD-PARTY-NOTICES.md`. |
| `ThirdParty/FMXPixie.VideoBackground.pas` | FMX-обёртка `FVideoBackground` поверх `TVideoPlayer`. |
| `Fix/FMX.Platform.Win.pas` | Изменённый платформенный модуль Windows из Embarcadero FireMonkey; распространяется на отдельных условиях. |
| `Examples/` | Демонстрационные проекты Inno Setup и вспомогательные файлы. |

## Сборка DLL

Инструкции по сборке и интеграции с Inno Setup приведены в [`BUILDING.md`](BUILDING.md).

В `FMXPixie.dpr` определены суффиксы DLL для соответствующих архитектур:

- Win32: `FMXPixie_x86.dll`
- Win64: `FMXPixie_x64.dll`

Каталоги вывода проекта: `Win32\Release\` и `Win64\Release\`. Перед компиляцией демонстрационных скриптов скопируйте соответствующие DLL в `Examples\Modules\`.

## Использование FMXPixie из Inno Setup

Для скрипта, расположенного непосредственно в каталоге `Examples\`, подключите файл интерфейсов:

~~~~iss
[Code]
#include "Modules\FMXPixieHandle.iss"
~~~~

Добавьте DLL соответствующей архитектуры в секцию `[Files]`, используя внутреннее имя `FMXPixie.dll`. Именно это имя импортируется в файле подключения:

~~~~iss
[Files]
#if SetupSetting("SetupArchitecture") == "x64"
Source: "Modules\FMXPixie_x64.dll"; DestName: "FMXPixie.dll"; Flags: dontcopy
#else
Source: "Modules\FMXPixie_x86.dll"; DestName: "FMXPixie.dll"; Flags: dontcopy
#endif
~~~~

Минимальный пример создания формы с использованием интерфейса, объявленного в файле подключения:

~~~~pascal
var
  FMXForm: FForm;

procedure InitializeWizard;
begin
  FMXForm := InitFormHandle;
  FMXForm.FCreateBlankForm(WizardForm.Handle, $FF202020, '', False);
  FMXForm.Caption('FMXPixie');
  FMXForm.Show;
end;
~~~~

Полный API объявлен в [`FMXPixieHandle.iss`](Examples/Modules/FMXPixieHandle.iss). При изменении экспортируемого интерфейса или метода синхронно обновляйте определения интерфейсов Delphi и объявления Pascal Script.

### Завершение работы

Текущий файл подключения предоставляет процедуры `FMXPixieShutDown` и `FMXPixieShutDownUn`. Они вызывают экспорт DLL для завершения работы, а затем вызывают Windows `EndTask` для окна выполнения Setup или Uninstall. Это вспомогательные процедуры завершения работы окна хост-приложения, а не универсальные обёртки `UnloadDLL` и не гарантия безопасной выгрузки произвольной DLL.

Для службы устройств ввода остановите опрос состояния и вызовите `FInput.Shutdown` до выгрузки FMXPixie, как описано в [README включённого FMXInput](ThirdParty/FMXInput/README.md). Перед завершением процесса хоста уничтожьте объекты FMX и остановите таймеры и службы.

## Модель API

DLL предоставляет фабричные функции, в том числе:

- `InitFormHandle` и `InitMsgFormHandle`
- `InitPixieHtmlView`, `InitPixieElementList`, `InitPixieElement` и `InitPixieDocument`
- `InitPixieSvgView`, `InitPixieMarkdownView`, `InitPixieTagBar` и `InitPixiePaintBox`
- `InitPixieAudioPlayer` и `InitInput`
- `InitTimer`, `InitStopwatch`, `InitStorageInfo` и `InitSystemInfo`

Слой интерфейсов использует интерфейсы `IUnknown` с GUID и дескрипторы объектов FMX размером с указатель. Файл подключения объявляет соответствующие типы и импорты Pascal Script, включая параметры `WideString` и сигнатуры обратных вызовов. Используйте эти объявления без изменений: не заменяйте типы строк или указателей другими представлениями.

## Благодарности и лицензирование

FMXPixie использует движок отрисовки Pixie, первоначально опубликованный SoftPerfect Pty Ltd и распространяемый по лицензии MIT. В проект также включена Windows-версия FMXInput от HemulGM и выбранные исходные файлы из FMXAudioLib и PCMAudio.

Видеопроигрыватель FMXPixie использует API-декларации Media Foundation из [MfPack](https://github.com/FactoryXCode/MfPack), проекта FactoryX с Delphi-описаниями Microsoft Media Foundation и связанных API Windows. На этой основе реализован интеграционный слой `TVideoPlayer`, а компонент `FVideoBackground` предоставляет его возможности в виде FMX-элемента. MfPack не является самостоятельным видеоплеером FMXPixie и не заменяет собственную реализацию `TVideoPlayer`.

Сведения об источниках кода, границах лицензий и компонентах, общих с FMXBridge, приведены в [`THIRD-PARTY-NOTICES.md`](THIRD-PARTY-NOTICES.md).

Корневой файл [`LICENSE`](LICENSE) распространяется только на оригинальный код, автором которого является audiofeel. Он не предоставляет прав на сторонний код или платформенные исходники Embarcadero.

## Лицензия

FMXPixie — репозиторий со смешанным составом исходного кода. Оригинальный код проекта, автором которого является audiofeel, распространяется по MIT; при этом отдельные каталоги и файлы регулируются собственными лицензиями и условиями правообладателей.

**Для MfPack важно учитывать оба upstream-документа.** API-декларации MfPack сопровождаются лицензией Mozilla Public License 2.0 и отдельным уведомлением автора, в котором указано ограничение на распространение исходного кода коммерческими пользователями в составе своего продукта. Это дополнительное уведомление не является стандартным текстом MPL-2.0. Его соотношение с MPL-2.0 требует отдельного разъяснения правообладателя. Перед коммерческим распространением затронутых исходников необходимо получить уточнение у автора MfPack.

Перед распространением репозитория или собранной DLL изучите [`LICENSE`](LICENSE) и [`THIRD-PARTY-NOTICES.md`](THIRD-PARTY-NOTICES.md). MIT-лицензия FMXPixie не отменяет лицензии и ограничения сторонних компонентов.
