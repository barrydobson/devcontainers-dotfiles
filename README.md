# Dotfile for Developer Containers

## Tools

- [Mise](https://github.com/jdx/mise) - A tool for managing multiple versions of programming languages and tools.
- [Zoxide](https://github.com/ajeetdsouza/zoxide) - A smarter cd command for your terminal.
- [Starship](https://starship.rs/) - A minimal, blazing-fast, and infinitely customizable prompt for any shell.

## Updating Scripts in `install.d`

To update the installation scripts in the `install.d` directory, follow these steps:

### Mise

```sh
curl https://mise.run -so install.d/mise
chmod +x install.d/mise
```

### Zoxide

```sh
curl https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh -so install.d/zoxide
chmod +x install.d/zoxide
```

### Starship

```sh
curl -fsSL https://starship.rs/install.sh -so install.d/starship
chmod +x install.d/starship
```
