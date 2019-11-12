# -*- coding: utf-8 -*-
import os
import click
import json
import logging
from urllib.request import urlretrieve


@click.command()
@click.argument('json_file', type=click.Path(exists=True))
def main(json_file):
    """ Downloads the bird images from Bird of the Year NZ to data/images
    """
    logger = logging.getLogger(__name__)

    logger.info("Loading json from: {}".format(json_file))
    with open(json_file, "r") as f:
        bird_json = json.load(f)

    for j in bird_json:
        image_extn = j['image'].rsplit(".", 1)[-1]
        image_filepath = os.path.join('data', 'images',
                                      j['url'].rsplit("/", 2)[-2] +
                                      '.' + image_extn)
        logger.info("Saving {} to {}".format(j['image'], image_filepath))
        urlretrieve(j['image'], image_filepath)


if __name__ == '__main__':
    log_fmt = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    logging.basicConfig(level=logging.INFO, format=log_fmt)

    main()

