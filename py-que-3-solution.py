import json
import sys


class DictMixin:
    def to_dict(self):
        return {k: v for k, v in self.__dict__.items() if not k.startswith('_')}


class JSONMixin:
    def to_json(self):
        try:
            return json.dumps(self.to_dict())
        except (TypeError, ValueError):
            raise TypeError("Object is not JSON serializable")


class MyClass(DictMixin, JSONMixin):
    def __init__(self, name, data, secret):
        self.name = name
        self.data = data
        self._secret = secret


def main():
    input_data = sys.stdin.read().split()
    idx = 0

    name = input_data[idx]; idx += 1
    data_type = input_data[idx]; idx += 1

    if data_type == 'int':
        data = int(input_data[idx]); idx += 1
    elif data_type == 'set':
        size = int(input_data[idx]); idx += 1
        data = set()
        for _ in range(size):
            data.add(int(input_data[idx])); idx += 1

    secret = input_data[idx]

    obj = MyClass(name, data, secret)

    print(obj.to_dict())

    try:
        print(obj.to_json())
    except TypeError as e:
        print(e)


if __name__ == "__main__":
    main()
