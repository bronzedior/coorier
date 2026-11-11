# Developer Guidelines

Welcome to the **Coorier** repository. Please follow the project structure, asset conventions, linting rules, and Git workflows detailed below to maintain a clean and scalable codebase.

---

## 1. Project Architecture & Folder Structure

We follow a modular Feature-based MVVM architecture:

```text
Coorier
├── Features
│   ├── Commons
│   │   ├── Components
│   │   ├── Services (Sound, Network, AR)
│   │   └── Resources (Asset, Color)
│   ├── HomePage
│   │   ├── Components
│   │   ├── View
│   │   ├── ViewModel
│   │   └── Model
│   └── RoomPage
│       ├── Components
│       ├── View
│       ├── ViewModel
│       └── Model
├── Tests

```

---

## 2. Project Setup & Configuration Guidelines

### Project Generation

* **Xcodegen Integration**: The repository uses `xcodegen` to generate the project workspace dynamically. Do **not** manually commit `.xcodeproj`, `.pbxproj`, or `Info.plist` files. Always modify `project.yml` and regenerate the project locally.

### Media & Asset Management

* **Image Assets**: Use `.png` format instead of `.svg`. Export all bitmap assets in `@1x`, `@2x`, and `@3x` scale factors.
* **Animations**: All vector animations must be rendered using **Lottie Framework** (`lottie-ios` by Airbnb).

### Code Quality & Formatting

* **SwiftLint**: The project enforces strict code style rules via `SwiftLint`. Resolve all lint warnings and errors before pushing code.

---

## 3. Git Workflow & Standards

### Commit Message Convention

Commit messages must be strictly in **lowercase** and include a functional scope where applicable.

```text
<type>(<scope>): <short description>

```

#### Allowed Types:

* `feat`: A new feature or component implementation (e.g., `feat(component): add custom primary button`).
* `mod`: Modifications or additions to an existing feature (e.g., `mod(home): append user badge to header`).
* `fix`: Bug fixes, layout adjustments, typos, or animation corrections (e.g., `fix(room): correct lottie alignment error`).
* `docs`: Documentation updates (e.g., `docs(readme): update build setup instructions`).

> **Note**: Do not list AI assistants as co-authors in your commits. All commits must be directly authored by the committer.

---

### Branching & Merging Strategy

#### Branch Naming Format:

```text
feat/<page_name>/dev/<developer_initials>

```

*Example:* `feat/home-page/dev/chg`

#### Merge Lifecycle:

1. **Development**: Work on your feature branch (`feat/<page_name>/dev/<developer_initials>`).
2. **Staging**: Open a Pull Request into the page-level staging branch (`feat/<page_name>`).
3. **Production**: Merge page staging branches into `main`. All team members are authorized to review and approve Pull Requests into `main`.
