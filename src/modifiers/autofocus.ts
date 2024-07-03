export function autofocus(node: HTMLInputElement) {
    const frame = requestAnimationFrame(() => {
        setTimeout(() => {
            node.focus();
            node.selectionStart = node.value.length;
            node.selectionEnd = node.value.length;
        });
    });
    return () => {
        cancelAnimationFrame(frame);
    }
}